CLASS zcl_co_fill_custo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_co_fill_custo IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    " Insert data into the zdt_co_custo table from harcoded values
    INSERT zdt_co_custo FROM TABLE @( VALUE #( (
       client = '100'             " Client of the system
       id = '008'                 " Identifier row of the table
       companycode = '1650'       " Company code
       glaccount = '0065400009'   " General ledger (GL) account
       actuals = 'N'              " Indicator for actuals
       plans = 'N'                " Indicator for plans
       type = 'POST'              " Type of record
       classification = ''        " Classification of record
       sign = '+'                 " Sign for the amount
       ) ) ).

    " Select all records from the zdt_co_custo table into the internal table lt_sql_entries
    SELECT * FROM zdt_co_custo INTO TABLE @DATA(lt_sql_entries).

    " Check if the selection was successful
    IF sy-subrc = 0.
      " Get the number of selected records
      DATA(numberofrecords) = lines( lt_sql_entries ).
      " Commented out: write the number of successfully inserted entries
      out->write( numberofrecords && ' entries inserted successfully ' ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
