CLASS zcl_test_08 DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.


CLASS zcl_test_08 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

*    READ ENTITIES OF z08_r_travel IN LOCAL MODE
*      ENTITY Travel
*        FIELDS ( TravelID AgencyID CustomerID BeginDate EndDate )
*        with
*      " TODO: variable is assigned but never used (ABAP cleaner)
*      RESULT DATA(lt_travel).

    out->write( 'Hello World' ).

  ENDMETHOD.

ENDCLASS.
