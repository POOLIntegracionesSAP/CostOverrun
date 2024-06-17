@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for Project - Detail Calc'
@Metadata.allowExtensions: true

// CDS view to select the corresponding values from the CDS of the Customizing table and to calculate the Cost Overrun
define view entity ZCDS_CO_PROJECT_DETAIL_CALC as select from ZCDS_CO_CUSTO as Custo
// Association to the Journal Entries CDS where the applicable entries are selected
association [1..*] to ZCDS_CO_PROJECT_DETAIL_JENTRY as _JournalEntries
    on _JournalEntries.glaccountjournal = Custo.Glaccount
    and _JournalEntries.companycode = Custo.CompanyCode

{
// The primary keys are Project and WBS related to the Journal Entry, and the Company Code, Type and Classification defined for the GLAccount in the Customizing table
    @EndUserText.label: 'Type'
key Custo.Type as type,
    @EndUserText.label: 'Classification'
key Custo.Classification as classification,
    @EndUserText.label: 'Project'
key _JournalEntries.project as project,
    @EndUserText.label: 'WBS'
key _JournalEntries.WBS as WBS,
    @EndUserText.label: 'Company Code'
key Custo.CompanyCode as companycode,
    @EndUserText.label: 'GLAccount'
    Custo.Glaccount as glaccount,
    @EndUserText.label: 'Company Code Currency'
    _JournalEntries.companycodecurrency,
// Only the posting amounts of journal entries whose GL Account is defined with the type "POST" in the Customizing table should be considered
// In such cases, all posting amounts for the same WBS will be summed
    @Semantics.amount.currencyCode: 'companycodecurrency'
    @EndUserText.label: 'Posting Amount'
    cast(case
        when Custo.Type = 'POST'
            then sum(curr_to_decfloat_amount(_JournalEntries.actualamount))
        else 0
        end as abap.decfloat34) as amountposting,
    @EndUserText.label: 'Actuals'
    Custo.Actuals as actuals,
// All actual amounts referenced to the same WBS will be summed, grouped by Type and Classification
// The Customizing table must define that the actuals should be considered in the calculation ("Y"), and it will multiply the value according to the sign defined
    @Semantics.amount.currencyCode: 'companycodecurrency'
    @EndUserText.label: 'Actual Amount'
    cast(case
        when Custo.Type = 'COST' and Custo.Classification = 'TIME' and Custo.Actuals = 'Y'
            then sum(curr_to_decfloat_amount(_JournalEntries.actualamount) * Custo.Multiply)
        when Custo.Type = 'COST' and Custo.Classification = 'MATERIAL' and Custo.Actuals = 'Y'
            then sum(curr_to_decfloat_amount(_JournalEntries.actualamount) * Custo.Multiply)
        when Custo.Type = 'REVENUE' and Custo.Actuals = 'Y'
            then sum(curr_to_decfloat_amount(_JournalEntries.actualamount) * Custo.Multiply)
        else 0
        end as abap.decfloat34) as actualamount_sum,
    @EndUserText.label: 'Plans'
    Custo.Plans as plans,
// All plan amounts referenced to the same WBS will be summed, grouped by Type and Classification
// The Customizing table must define that the plans should be considered in the calculation ("Y"), and it will multiply the value according to the sign defined
    @Semantics.amount.currencyCode: 'companycodecurrency'
    @EndUserText.label: 'Plan Amount'
    cast(case 
        when Custo.Type = 'COST' and Custo.Classification = 'TIME' and Custo.Plans = 'Y'
            then sum(curr_to_decfloat_amount(_JournalEntries.planamount) * Custo.Multiply)
        when Custo.Type = 'COST' and Custo.Classification = 'MATERIAL' and Custo.Plans = 'Y'
            then sum(curr_to_decfloat_amount(_JournalEntries.planamount) * Custo.Multiply)
        when Custo.Type = 'REVENUE' and Custo.Plans = 'Y'
            then sum(curr_to_decfloat_amount(_JournalEntries.planamount) * Custo.Multiply)
        else 0
        end as abap.decfloat34) as planamount_sum,

// -- Associations --

    _JournalEntries

}
// Grouping of values to discard duplicates
group by _JournalEntries.project, _JournalEntries.WBS, Custo.CompanyCode, Custo.Glaccount, _JournalEntries.companycodecurrency, Custo.Actuals,
         Custo.Plans, Custo.Type, Custo.Classification
// Condition to remove the Journal Entries that are not associated to any project
having
    count(distinct _JournalEntries.project) != 0
