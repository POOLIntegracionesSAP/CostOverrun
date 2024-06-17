@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for SO - Open SO'
@Metadata.allowExtensions: true

// CDS view used by the value help CDS where the open sales orders are selected
define view entity ZCDS_CO_SO_FILTER_SO_OPEN as select from I_SalesOrder as SalesOrder
// Obtaining the SO Items associated with each sales order obtained from the main view
inner join I_SalesOrderItem as SOItem
    on SalesOrder.SalesOrder = SOItem.SalesOrder
{
// The primary keys is the Sales Order
    @EndUserText.label: 'Sales Order'
key SalesOrder.SalesOrder as salesorder,
    @EndUserText.label: 'Sales Order Item'
    SOItem.SalesOrderItem as salesorderitem,
    @EndUserText.label: 'Sales Organization'
    SalesOrder.SalesOrganization as salesorganization,
    @EndUserText.label: 'Delivery Block'
    SalesOrder.DeliveryBlockReason as deliveryblock,
    @EndUserText.label: 'Overall SD Status'
    SalesOrder.OverallSDProcessStatus as overallstatus,
// Conversion of the Last Change Date Time of the sales order from type timestamp to a data type that displays the date of the last modification
    @EndUserText.label: 'Last Change Date'
    cast(substring(cast(SalesOrder.LastChangeDateTime as abap.char(24)),1,8) as abap.dats) as lastchangedate
    
}
// The sales orders to be considered must be in the Open or In Progress status ("A" or "B"), must not be related to any WBS Element, and not have a Delivery Block ("53")
where
    SalesOrder.DeliveryBlockReason != '53' 
    and (SalesOrder.OverallSDProcessStatus = 'A' or SalesOrder.OverallSDProcessStatus = 'B')
    and SOItem.WBSElementInternalID = '00000000'
// Grouping of values to discard duplicates
group by SalesOrder.SalesOrganization, SalesOrder.SalesOrder, SOItem.SalesOrderItem, SalesOrder.DeliveryBlockReason, SalesOrder.OverallSDProcessStatus,
         SalesOrder.LastChangeDateTime
