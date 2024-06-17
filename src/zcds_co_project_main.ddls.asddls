@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Cost Overrun for Project'
@Metadata.allowExtensions: true

// Main CDS view to select the relevant values from the Cost Overrun calculation
define root view entity ZCDS_CO_PROJECT_MAIN
// Parameter defined as mandatory input, needed to run the calculation (should be the last day of the previous month)
with parameters
    @EndUserText.label: 'Posting Date Up To'
    p_postingdate: zde_co_date
as select from I_EnterpriseProject as EP
// Obtaining the Project Elements (WBS Elements) associated with each project obtained from the main view
inner join I_EnterpriseProjectElement as WBS
    on WBS.ProjectInternalID = EP.ProjectInternalID
// Associations to the main CDS views of the calculation process to get the details needed
association [1..*] to ZCDS_CO_PROJECT_DETAIL_JENTRY as _JournalEntries
    on _JournalEntries.project = EP.Project
    and _JournalEntries.WBS = WBS.ProjectElement
association [1..*] to ZCDS_CO_PROJECT_DETAIL_POSTING as _Posting
    on _Posting.project = EP.ProjectInternalID
    and _Posting.WBS = WBS.WBSElementInternalID
association [1..*] to ZCDS_CO_PROJECT_DETAIL_PROJECT as _DetailProject
    on _DetailProject.project = EP.Project
    and _DetailProject.WBS = WBS.ProjectElement
association [1..*] to ZCDS_CO_PROJECT_SUMMARY_CALC as _Calculation
    on _Calculation.project = EP.Project
    and _Calculation.WBS = WBS.ProjectElement
{
// The primary keys are Company Code, Project and WBS
// Company Code field is a mandatory input, needed to run the calculation. Value Help (standard CDS view) provided to facilitate the selection of the values
    @EndUserText.label: 'Company Code'
    @Consumption.valueHelpDefinition: [{ entity: {name: 'I_CompanyCode', element: 'CompanyCode'} }]
    @Consumption.filter: {mandatory: true}
key EP.CompanyCode as companycode,
// Value Help (custom CDS view) provided to facilitate the selection of the values. Selected company code in the main view is taken into account in the value help
    @EndUserText.label: 'Project'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCDS_CO_PROJECT_FILTER_PROJECT', element: 'project' },
                                         additionalBinding: [{ element: 'companycode', localElement: 'companycode' }]}]
key EP.Project as project,
    @EndUserText.label: 'WBS Element'
key WBS.ProjectElement as WBS,
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

    EP.ProjectInternalID,
    WBS.WBSElementInternalID,
    
    _JournalEntries.companycodecurrency as companycodecurrency,

// -- Parameters --

    $parameters.p_postingdate as postingdate,
    
// -- Associations --

    _DetailProject,
    _JournalEntries,
    _Posting,
    _Calculation
    
}
// The projects to be considered must have the profile "Project with Revenue" ("YP05")
// If the project is in status Open ("10"), the last change date of the project must be equal to or earlier than the "Posting Date Up To" determined by the user
// If the project is in status Closed ("40"), the last change date of the project must be later than the "Posting Date Up to" determined by the user
// and must have a previous posting in the previous month of the "Posting Date Up To" month
where
    EP.ProjectProfileCode = 'YP05'
    and ((tstmp_to_dats(EP.ProjectLastChangedDateTime,abap_system_timezone($session.client,'NULL'),$session.client,'NULL') <= $parameters.p_postingdate and EP.ProcessingStatus = '10')
    or (tstmp_to_dats(EP.ProjectLastChangedDateTime,abap_system_timezone($session.client,'NULL'),$session.client,'NULL') > $parameters.p_postingdate and EP.ProcessingStatus = '40'))
        and substring(_Posting.documentdateposting,5,2) = substring(dats_add_months($parameters.p_postingdate,-1,'UNCHANGED'),5,2)
// Grouping of values to discard duplicates
group by EP.CompanyCode, EP.Project, WBS.ProjectElement, EP.ProjectInternalID, WBS.WBSElementInternalID, _Calculation.forecast_eac, _Calculation.amountposting, _JournalEntries.companycodecurrency, _Calculation.totalamount
            ,_Posting.documentdateposting
// At least, a WBS must have a Journal Entry or a Previous Posting to be taken into consideration in the calculation of the Cost Overrun
having
    count(distinct _JournalEntries.glaccountjournal) != 0
    or count(distinct _Posting.glaccountposting) != 0
