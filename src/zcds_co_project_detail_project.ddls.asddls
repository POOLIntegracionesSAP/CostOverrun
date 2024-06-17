@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for Project - DetailProject'
@Metadata.allowExtensions: true

// CDS view to select the fields related to the detail information of each WBS
define view entity ZCDS_CO_PROJECT_DETAIL_PROJECT as select from I_EnterpriseProject as EP
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
key WBS.ProjectElement as WBS,
    @EndUserText.label: 'Project Description'
    EP.ProjectDescription as projectdescription,
    @EndUserText.label: 'WBS Element Description'
    WBS.ProjectElementDescription as WBSdescription,
    @EndUserText.label: 'Processing Status'
    EP.ProcessingStatus as processingstatus,   
    @EndUserText.label: 'Project Profile Code'
    EP.ProjectProfileCode as projectprofile,
// Conversion of the Last Change Date Time of the project from type timestamp to a data type that displays the date of the last modification
    @EndUserText.label: 'Last Change Date'
    (tstmp_to_dats(EP.ProjectLastChangedDateTime,abap_system_timezone($session.client,'NULL'),$session.client,'NULL')) as projectlastchangeddate
}
