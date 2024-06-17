@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for SO - Filter - SO'
@Metadata.allowExtensions: true

// CDS view used as a value help where the main fields of the sales order are gathered
define view entity ZCDS_CO_SO_FILTER_SO as select from I_SalesOrder as SalesOrder
// Association to the custom Sales Order CDS where the applicable sales orders are selected (opened and closed)
association [0..*] to ZCDS_CO_SO_FILTER_SO_OPEN as _SO_Open
    on _SO_Open.salesorganization = SalesOrder.SalesOrganization
association [0..*] to ZCDS_CO_SO_FILTER_SO_CLOSE as _SO_Closed
    on _SO_Closed.salesorganization = SalesOrder.SalesOrganization
{
// The primary keys are Sales Organization and Sales Order
    @EndUserText.label: 'Sales Organization'
key SalesOrder.SalesOrganization as salesorganization,
    @EndUserText.label: 'Sales Order'
key SalesOrder.SalesOrder as salesorder,
// Conversion of the Last Change Date Time of the sales order from type timestamp to a data type that displays the date of the last modification
    @EndUserText.label: 'Last Change Date'
    cast(substring(cast(SalesOrder.LastChangeDateTime as abap.char(24)),1,8) as abap.dats) as postingdateupto,

// -- Associations --
   
    _SO_Open,
    _SO_Closed
    
}
// Grouping of values to discard duplicates
group by SalesOrder.SalesOrganization, SalesOrder.SalesOrder, SalesOrder.LastChangeDateTime
