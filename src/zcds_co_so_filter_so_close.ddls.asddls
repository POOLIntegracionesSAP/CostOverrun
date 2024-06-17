@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for SO - Closed SO'
@Metadata.allowExtensions: true

// CDS view used by the value help CDS where the closed sales orders are selected
define view entity ZCDS_CO_SO_FILTER_SO_CLOSE as select from I_SalesOrder as SalesOrder
// Obtaining the SO Items associated with each sales order obtained from the main view, and the corresponding previous postings for each SO Item
inner join I_SalesOrderItem as SOItem
    on SalesOrder.SalesOrder = SOItem.SalesOrder
inner join I_GLAccountLineItem as GLAccountItem
    on SOItem.SalesOrder = GLAccountItem.SalesDocument
    and SOItem.SalesOrderItem = GLAccountItem.SalesDocumentItem
{
// The primary keys are Sales Organization, Sales Order, SO Item and the GL Account of the posting
    @EndUserText.label: 'Sales Order'
key SalesOrder.SalesOrder as salesorder,
    @EndUserText.label: 'Sales Order Item'
key SOItem.SalesOrderItem as salesorderitem,
    @EndUserText.label: 'Sales Organization'
key SalesOrder.SalesOrganization as salesorganization,
    @EndUserText.label: 'Posting Account'
key GLAccountItem.GLAccount as glaccountposting,
    @EndUserText.label: 'Delivery Block'
    SalesOrder.DeliveryBlockReason as deliveryblock,
    @EndUserText.label: 'Overall SD Status'
    SalesOrder.OverallSDProcessStatus as overallstatus,
    @EndUserText.label: 'Last Change Date'
// Conversion of the Last Change Date Time of the sales order from type timestamp to a data type that displays the date of the last modification
    cast(substring(cast(SalesOrder.LastChangeDateTime as abap.char(24)),1,8) as abap.dats) as lastchangedate,
    @EndUserText.label: 'Currency'
    GLAccountItem.CompanyCodeCurrency as companycodecurrency,
    @EndUserText.label: 'Posting Amount'
    GLAccountItem.AmountInCompanyCodeCurrency as amountposting,    
    @EndUserText.label: 'Document Date'
    GLAccountItem.DocumentDate as documentdateposting
}
// The sales orders to be considered must be in the Closed status ("C"), must not be related to any WBS Element, and have a previous posting with the
// corresponding GL Account ("0065400009") and Ledger ("0L")
where
    (SalesOrder.OverallSDProcessStatus = 'C')
    and SOItem.WBSElementInternalID = '00000000'
    and GLAccountItem.GLAccount = '0065400009'
    and GLAccountItem.Ledger = '0L'
// Grouping of values to discard duplicates
group by SalesOrder.SalesOrganization, SalesOrder.SalesOrder, SOItem.SalesOrderItem, SalesOrder.DeliveryBlockReason, SalesOrder.OverallSDProcessStatus,
         SalesOrder.LastChangeDateTime, GLAccountItem.GLAccount, GLAccountItem.CompanyCodeCurrency, GLAccountItem.AmountInCompanyCodeCurrency, GLAccountItem.DocumentDate
