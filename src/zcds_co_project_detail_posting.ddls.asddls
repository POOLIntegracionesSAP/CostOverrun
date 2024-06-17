@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CostOverrun for Project - DetailPostings'
@Metadata.allowExtensions: true

// CDS view to select the postings created in the system for each WBS Element
define view entity ZCDS_CO_PROJECT_DETAIL_POSTING as select from I_GLAccountLineItem as GLAccountItem

{
// The primary keys are CompanyCode, DocumentDate and GLAccount related to the Posting
    @EndUserText.label: 'Posting Account'
key GLAccountItem.GLAccount as glaccountposting,
    @EndUserText.label: 'Company Code'
key GLAccountItem.CompanyCode as companycode,
    @EndUserText.label: 'Document Date'
key GLAccountItem.DocumentDate as documentdateposting,
    @EndUserText.label: 'Sales Order'
    GLAccountItem.ProjectInternalID as project,
    @EndUserText.label: 'WBS'
    GLAccountItem.WBSElementInternalID as WBS,
    @EndUserText.label: 'Currency'
    GLAccountItem.CompanyCodeCurrency as companycodecurrency,
    @EndUserText.label: 'Posting Amount'
    GLAccountItem.AmountInCompanyCodeCurrency as amountposting
    
}
// The postings to be considered are those associated with a WBS element, related to ledger "0L" and to the posting GL Account "0065400009"
where
    GLAccountItem.GLAccount = '0065400009'
    and GLAccountItem.Ledger = '0L'
    and GLAccountItem.WBSElementInternalID is not initial
