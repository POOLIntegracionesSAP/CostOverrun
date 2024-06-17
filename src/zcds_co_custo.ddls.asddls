@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun - Customizing'
@Metadata.allowExtensions: true

// CDS view to select from the Customizing table where the GLAccounts to be considered in the Cost Overrun calculation are defined
define view entity ZCDS_CO_CUSTO as select from zdt_co_custo

{
// Company Code as primary key of the CDS view
    key companycode as CompanyCode,
    glaccount as Glaccount,
    actuals as Actuals,
    plans as Plans,
    type as Type,
    classification as Classification,
    sign as Sign,
// If Sign is '+', set Mutiply to 1 for the Overrun calculation
// If Sign is '-', set Mutiply to -1 for the Overrun calculation
    cast(case
        when sign = '+'
            then '1'
        when sign = '-'
            then '-1'
        end as abap.decfloat34) as Multiply
}
