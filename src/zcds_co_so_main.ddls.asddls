@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cost Overrun for Sales Order'
@Metadata.allowExtensions: true

// Main CDS view to select the relevant values from the Cost Overrun calculation
define root view entity ZCDS_CO_SO_MAIN
// Parameter defined as mandatory input, needed to run the calculation (should be the last day of the previous month)
with parameters
    @EndUserText.label: 'Posting Date Up To'
    p_postingdate: zde_co_date
as select from I_SalesOrder as SO
// Obtaining the SO Items associated with each sales order obtained from the main view
inner join I_SalesOrderItem as SOItem
    on SO.SalesOrder = SOItem.SalesOrder
// Associations to the main CDS views of the calculation process to get the details needed
association [1..*] to ZCDS_CO_SO_DETAIL_JENTRY as _JournalEntries
    on _JournalEntries.salesdoc = SOItem.SalesOrder
    and _JournalEntries.salesdocitem = SOItem.SalesOrderItem
association [1..*] to ZCDS_CO_SO_DETAIL_POSTING as _Posting
    on _Posting.salesdoc = SOItem.SalesOrder
    and _Posting.salesdocitem = SOItem.SalesOrderItem
association [1..*] to ZCDS_CO_SO_DETAIL_SALESORDER as _DetailSO
    on _DetailSO.salesorder = SOItem.SalesOrder
    and _DetailSO.salesorderitem = SOItem.SalesOrderItem
association [1..*] to ZCDS_CO_SO_SUMMARY_CALC as _Calculation
    on _Calculation.salesdoc = SOItem.SalesOrder
    and _Calculation.salesdocitem = SOItem.SalesOrderItem
{
// The primary keys are Sales Organization, Sales Order and SO Item
// Sales Organization field is a mandatory input, needed to run the calculation. Value Help (standard CDS view) provided to facilitate the selection of the values
    @EndUserText.label: 'Sales Organization'
    @Consumption.valueHelpDefinition: [{ entity: {name: 'I_SalesOrganization', element: 'SalesOrganization'} }]
    @Consumption.filter: {mandatory: true}
key SO.SalesOrganization as salesorganization,
// Value Help (custom CDS view) provided to facilitate the selection of the values. Selected sales organization in the main view is taken into account in the value help
    @EndUserText.label: 'Sales Order'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCDS_CO_SO_FILTER_SO', element: 'salesorder' },
                                         additionalBinding: [{ element: 'salesorganization', localElement: 'salesorganization' }]}]
key SOItem.SalesOrder as salesorder,
    @EndUserText.label: 'Sales Order Item'
key SOItem.SalesOrderItem as salesorderitem,
    @EndUserText.label: 'Forecast'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    _Calculation.forecast_eac as forecast,
    @EndUserText.label: 'Previous Posting'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    _Calculation.amountposting as previousposting,
    @EndUserText.label: 'Total Amount to Post'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    _Calculation.totalamount as totalamount,
// If the total amount is positive, a posting (with this amount) is needed
// If the total amount is 0 or negative, there is not needed any posting
    @EndUserText.label: 'Posting'
    case
        when $projection.totalamount > 0
            then 'Yes'
        else 'Not'
        end as posting,

// -- Additional Fields --

    _JournalEntries.companycodecurrency as companycodecurrency,
    
// -- Parameters --
    
    $parameters.p_postingdate as postingdate,
    
// -- Associations --
    
    _JournalEntries,
    _Posting,
    _DetailSO,
    _Calculation

}
// The sales order items to be considered must not have a WBS element associated
// If the sales order is in status Open or In Progress ("A" or "B"), the last change date of the sales order must be equal to or earlier than the "Posting Date Up To" determined by the user
// If the sales order is in status Closed ("C"), the last change date of the sales order must be later than the "Posting Date Up to" determined by the user
// and must have a previous posting in the previous month of the "Posting Date Up To" month
where
    SOItem.WBSElementInternalID = '00000000'
    and ((cast(substring(cast(SO.LastChangeDateTime as abap.char(24)),1,8) as abap.dats) <= $parameters.p_postingdate
        and SO.DeliveryBlockReason != '53' and (SO.OverallSDProcessStatus = 'A' or SO.OverallSDProcessStatus = 'B'))
    or (cast(substring(cast(SO.LastChangeDateTime as abap.char(24)),1,8) as abap.dats) > $parameters.p_postingdate
        and substring(_Posting.documentdateposting,5,2) = substring(dats_add_months($parameters.p_postingdate,-1,'UNCHANGED'),5,2)
        and SO.OverallSDProcessStatus = 'C'))
// Grouping of values to discard duplicates
group by SO.SalesOrganization, SOItem.SalesOrder, SOItem.SalesOrderItem, _Calculation.forecast_eac, _Calculation.amountposting, _JournalEntries.companycodecurrency, _Calculation.totalamount
            ,_Posting.documentdateposting
// At least, a SO Item must have a Journal Entry or a Previous Posting to be taken into consideration in the calculation of the Cost Overrun
having
    count(distinct _JournalEntries.glaccountjournal) != 0
    or count(distinct _Posting.glaccountposting) != 0
