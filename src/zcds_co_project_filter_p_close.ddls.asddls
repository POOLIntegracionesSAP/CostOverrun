@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for Project - ClosedProject'
@Metadata.allowExtensions: true

// CDS view used by the value help CDS where the closed projects are selected
define view entity ZCDS_CO_PROJECT_FILTER_P_CLOSE as select from I_EnterpriseProject as EP
// Obtaining the Project Elements (WBS Elements) associated with each project obtained from the main view, and the corresponding previous postings for each WBS
inner join I_EnterpriseProjectElement as WBS
    on WBS.ProjectInternalID = EP.ProjectInternalID
inner join I_GLAccountLineItem as GLAccountItem
    on WBS.ProjectInternalID = GLAccountItem.WBSElementInternalID
    and WBS.ProjectInternalID = GLAccountItem.WBSElementInternalID
{
// The primary keys are Company Code, Project, WBS and the GL Account of the posting
    @EndUserText.label: 'Company Code'
key EP.CompanyCode as companycode,
    @EndUserText.label: 'Project'
key EP.Project as project,
    @EndUserText.label: 'WBS Element'
key WBS.ProjectElement as wbs,
    @EndUserText.label: 'Posting Account'
key GLAccountItem.GLAccount as glaccountposting,
// Conversion of the Last Change Date Time of the project from type timestamp to a data type that displays the date of the last modification
    @EndUserText.label: 'Last Change Date'
    (tstmp_to_dats(EP.ProjectLastChangedDateTime,abap_system_timezone($session.client,'NULL'),$session.client,'NULL')) as lastchangedate,
    @EndUserText.label: 'Currency'
    GLAccountItem.CompanyCodeCurrency as companycodecurrency,
    @EndUserText.label: 'Posting Amount'
    GLAccountItem.AmountInCompanyCodeCurrency as amountposting,    
    @EndUserText.label: 'Document Date'
    GLAccountItem.DocumentDate as documentdateposting
}
// The projects to be considered must have the profile "Project with Revenue" ("YP05"), be in the Closed status ("40"), and have a previous posting with the
// corresponding GL Account ("0065400009") and Ledger ("0L")
where
    EP.ProjectProfileCode = 'YP05'
    and EP.ProcessingStatus = '40'
    and GLAccountItem.GLAccount = '0065400009'
    and GLAccountItem.Ledger = '0L'
// Grouping of values to discard duplicates
group by EP.CompanyCode, EP.Project, WBS.ProjectElement, GLAccountItem.GLAccount, EP.ProjectLastChangedDateTime, 
         GLAccountItem.CompanyCodeCurrency, GLAccountItem.AmountInCompanyCodeCurrency, GLAccountItem.DocumentDate
