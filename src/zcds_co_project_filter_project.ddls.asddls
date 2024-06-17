@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun Project - Filter - Project'
@Metadata.allowExtensions: true

// CDS view used as a value help where the main fields of the project are gathered
define view entity ZCDS_CO_PROJECT_FILTER_PROJECT as select from I_EnterpriseProject as EP
// Association to the custom Project CDS where the applicable projects are selected (opened and closed)
association [0..*] to ZCDS_CO_PROJECT_FILTER_P_OPEN as _Open
    on _Open.companycode = EP.CompanyCode
association [0..*] to ZCDS_CO_PROJECT_FILTER_P_CLOSE as _Closed
    on _Closed.companycode = EP.CompanyCode
{
// The primary keys are Company Code and Project
    @EndUserText.label: 'Company Code'
key EP.CompanyCode as companycode,
    @EndUserText.label: 'Project'
key EP.Project as project,
    @EndUserText.label: 'Project Description'
    EP.ProjectDescription as projectdescription,
// Conversion of the Last Change Date Time of the project from type timestamp to a data type that displays the date of the last modification
    @EndUserText.label: 'Last Change Date'
    (tstmp_to_dats(EP.ProjectLastChangedDateTime,abap_system_timezone($session.client,'NULL'),$session.client,'NULL')) as lastchangedate,

// -- Associations --
    _Closed,
    _Open

}
// Grouping of values to discard duplicates
group by EP.CompanyCode, EP.Project, EP.ProjectDescription, EP.ProjectLastChangedDateTime
