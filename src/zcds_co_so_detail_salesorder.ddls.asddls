@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for SO - Detail SO'
@Metadata.allowExtensions: true

// CDS view to select the fields related to the detail information of each SO Item
define view entity ZCDS_CO_SO_DETAIL_SALESORDER as select from I_SalesOrder as SO
// Obtaining the SO Item associated with each sales order obtained from the main view
inner join I_SalesOrderItem as SOItem
    on SO.SalesOrder = SOItem.SalesOrder
{
// The primary keys are Sales Organization, Sales Order and Sales Order Item
    @EndUserText.label: 'Sales Organization'
key SO.SalesOrganization as salesorganization,
    @EndUserText.label: 'Sales Order'
key SOItem.SalesOrder as salesorder,
    @EndUserText.label: 'Sales Order Item'
key SOItem.SalesOrderItem as salesorderitem,
    @EndUserText.label: 'Delivery Block'
    SO.DeliveryBlockReason as deliveryblock,
    @EndUserText.label: 'Overall SD Status'
    SO.OverallSDProcessStatus as overallstatus,
// Conversion of the Last Change Date Time of the sales order from type timestamp to a data type that displays the date of the last modification
    @EndUserText.label: 'Last Change Date'
    cast(substring(cast(SO.LastChangeDateTime as abap.char(24)),1,8) as abap.dats) as lastchangedate,
    @EndUserText.label: 'WBS Element'
    SOItem.WBSElementInternalID as WBS,
    
// -- Additional Fields --

    SO.LastChangeDateTime as lastchangetimestamp
}
