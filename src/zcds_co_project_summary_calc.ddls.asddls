@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cost Overrun for Project - Summary Calc'
@Metadata.allowExtensions: true

// CDS view to select the main values from the Cost Overrun calculation for summarization purposes
define view entity ZCDS_CO_PROJECT_SUMMARY_CALC as select from ZCDS_CO_PROJECT_DETAIL_CALC as DetailCalculation
{
// The primary keys are Company Code, Project, WBS and the combination of Type and Classification
    @EndUserText.label: 'Company Code'
key DetailCalculation.companycode as companycode,
    @EndUserText.label: 'Project'
key DetailCalculation.project as project,
    @EndUserText.label: 'WBS'
key DetailCalculation.WBS as WBS,
// Combination of Type and Classification defined for the GL Account in the Customizing table
    @EndUserText.label: 'Type - Classification'
key cast(concat_with_space(DetailCalculation.type, DetailCalculation.classification, 1) as abap.char( 100 )) as typeclass,
// Sum of the actual amounts for all entries of the WBS Element
    @EndUserText.label: 'ACDOCA'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    cast(DetailCalculation.actualamount_sum as abap.curr( 10, 2 )) as actualamount_sum,
// Sum of the plan amounts for all entries of the WBS Element
    @EndUserText.label: 'ACDOCP'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    cast(DetailCalculation.planamount_sum as abap.curr( 10, 2 )) as planamount_sum,
// For cases where the type is "COST", if the difference between the actuals amount and the plans amount is positive, it will allocate a 0
// In case it's negative, it will allocate the negative value
// For cases where the type is "REVENUE", if the difference between the actuals amount and the plans amount is negative, it will allocate a 0
// In case it's positive, it will allocate the positive value
    @EndUserText.label: 'Forecast ETC'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    cast(case
        when DetailCalculation.type = 'COST' and DetailCalculation.actualamount_sum - DetailCalculation.planamount_sum < 0
            then DetailCalculation.actualamount_sum - DetailCalculation.planamount_sum
        when DetailCalculation.type = 'REVENUE' and DetailCalculation.actualamount_sum - DetailCalculation.planamount_sum >= 0
            then DetailCalculation.actualamount_sum - DetailCalculation.planamount_sum
        else 0
        end as abap.curr( 10, 2 )) as forecast_etc,
// Sum of the forecast ETC amount and the plan amount
    @EndUserText.label: 'Forecast EAC'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    cast(cast(DetailCalculation.planamount_sum as abap.decfloat34) + cast($projection.forecast_etc as abap.decfloat34) as abap.curr( 10, 2 )) as forecast_eac,
// Posting amount casted to a currency type
    @EndUserText.label: 'Posting Amount'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    cast(DetailCalculation.amountposting as abap.curr( 10, 2 )) as amountposting,
// The total value to post will be the difference between the Forecast EAC amount and the previous posting amount
    @EndUserText.label: 'Total Amount to Post'
    @Semantics.amount.currencyCode: 'companycodecurrency'
    $projection.forecast_eac - $projection.amountposting as totalamount,

// -- Additional Fields --

    DetailCalculation.glaccount,
    DetailCalculation.companycodecurrency,

// -- Associations --

    _JournalEntries

}
