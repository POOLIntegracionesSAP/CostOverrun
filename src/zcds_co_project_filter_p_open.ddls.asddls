@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for Project - Open Project'
@Metadata.allowExtensions: true

// CDS view used by the value help CDS where the open projects are selected
define view entity ZCDS_CO_PROJECT_FILTER_P_OPEN as select from I_EnterpriseProject as EP
// Obtaining the Project Elements (WBS Elements) associated with each project obtained from the main view
inner join I_EnterpriseProjectElement as WBS
    on WBS.ProjectInternalID = EP.ProjectInternalID
{
// The primary keys are Company Code, Project and WBS
    @EndUserText.label: 'Company Code'
key EP.CompanyCode as companycode,
    @EndUserText.label: 'Project'
key EP.Project as project,
    @EndUserText.label: 'WBS Element'
key WBS.ProjectElement as wbs
}
// The projects to be considered must have the profile 'Project with Revenue' ('YP05') and be in the Released status ('10')
where
    EP.ProjectProfileCode = 'YP05'
    and EP.ProcessingStatus = '10'
// Grouping of values to discard duplicates
group by EP.CompanyCode, EP.Project, WBS.ProjectElement
