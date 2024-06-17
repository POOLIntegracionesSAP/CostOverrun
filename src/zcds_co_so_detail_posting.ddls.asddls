@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CostOverrun for SO - DetailPostings'
@Metadata.allowExtensions: true

// CDS view to select the postings created in the system for each SO Item
define view entity ZCDS_CO_SO_DETAIL_POSTING as select from I_GLAccountLineItem as GLAccountItem
{
// The primary keys are CompanyCode, DocumentDate and GLAccount related to the Posting
    @EndUserText.label: 'Posting Account'
key GLAccountItem.GLAccount as glaccountposting,
    @EndUserText.label: 'Company Code'
key GLAccountItem.CompanyCode as companycode,
    @EndUserText.label: 'Document Date'
key GLAccountItem.DocumentDate as documentdateposting,
    @EndUserText.label: 'Sales Organization'
    GLAccountItem.SalesOrganization as salesorganization,
    @EndUserText.label: 'Sales Order'
    GLAccountItem.SalesDocument as salesdoc,
    @EndUserText.label: 'Sales Order Item'
    GLAccountItem.SalesDocumentItem as salesdocitem,
    @EndUserText.label: 'Currency'
    GLAccountItem.CompanyCodeCurrency as companycodecurrency,
    @EndUserText.label: 'Posting Amount'
    GLAccountItem.AmountInCompanyCodeCurrency as amountposting
    
}
// The postings to be considered are those associated with a Sales Order, related to ledger "0L" and to the posting GL Account "0065400009"
where
    GLAccountItem.GLAccount = '0065400009'
    and GLAccountItem.Ledger = '0L'
    and GLAccountItem.SalesDocument <> ''
