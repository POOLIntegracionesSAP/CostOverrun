@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CostOverrun for SO - Detail JournalEntry'
@Metadata.allowExtensions: true

// CDS view to select the journal entries created in the system for each SO Item
define view entity ZCDS_CO_SO_DETAIL_JENTRY as select from I_ActualPlanJournalEntryItem as JournalEntryItem

{
// The primary keys are Ledger and GLAccount related to the Journal Entry
    @EndUserText.label: 'Ledger'
key JournalEntryItem.Ledger as ledger,
    @EndUserText.label: 'Journal Account'
key JournalEntryItem.GLAccount as glaccountjournal,
    @EndUserText.label: 'Sales Organization'
    JournalEntryItem.SalesOrganization as salesorganization,
    @EndUserText.label: 'Sales Order'
    JournalEntryItem.SalesDocument as salesdoc,
    @EndUserText.label: 'Sales Order Item'
    JournalEntryItem.SalesDocumentItem as salesdocitem,
    @EndUserText.label: 'Company Code'
    JournalEntryItem.CompanyCode as companycode,
    @EndUserText.label: 'Plan Category'
    JournalEntryItem.PlanningCategory as planningcategory,
    @EndUserText.label: 'Profit Center'
    JournalEntryItem.ProfitCenter as profitcenter,
    @EndUserText.label: 'Fiscal Year'
    JournalEntryItem.FiscalYear as fiscalyear,
    @EndUserText.label: 'Fiscal Period'
    JournalEntryItem.FiscalYearPeriod as fiscalperiod,
    @EndUserText.label: 'Currency'
    JournalEntryItem.CompanyCodeCurrency as companycodecurrency,
    @EndUserText.label: 'Actual Amount'
    JournalEntryItem.ActualAmountInCompanyCodeCrcy as actualamount,
    @EndUserText.label: 'Plan Amount'
    JournalEntryItem.PlanAmountInCompanyCodeCrcy as planamount
    
}
// The journal entries to be considered are those associated with a Sales Order, related to ledger "0L", and having a planning category of "ATC01" or "ZPLN"
where
    (JournalEntryItem.PlanningCategory = 'ACT01' or JournalEntryItem.PlanningCategory = 'ZPLN')
    and JournalEntryItem.Ledger = '0L'
    and JournalEntryItem.SalesDocument <> ''
