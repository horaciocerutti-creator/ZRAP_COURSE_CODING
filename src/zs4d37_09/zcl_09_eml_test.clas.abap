CLASS zcl_09_eml_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070009'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004179'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_09_eml_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

*    READ ENTITIES OF z09_r_travel
*        ENTITY z09_r_travel
*        ALL FIELDS WITH VALUE #( ( AgencyId = c_agency_id TravelId = c_travel_id ) )
*        RESULT DATA(lt_result)
*        FAILED DATA(lt_failed).
**
*    IF lt_failed IS NOT INITIAL.
*      out->write( 'Error:' ).
*      out->write( lt_failed ).
*    ELSE.
*      out->write( 'Found:' ).
*      out->write( lt_result ).
*    ENDIF.

    DATA travels TYPE TABLE FOR UPDATE z09_r_travel.
    DATA travel TYPE STRUCTURE FOR UPDATE z09_r_travel.

    DATA failed TYPE RESPONSE FOR FAILED z09_r_travel.
    DATA failed_late TYPE RESPONSE FOR FAILED LATE z09_r_travel.

*    READ ENTITIES OF z09_r_travel
*        ENTITY Travel
*        ALL FIELDS WITH VALUE #( ( AgencyId = c_agency_id TravelId = c_travel_id ) )
*        RESULT DATA(lt_result)
*        FAILED DATA(lt_failed).
*
* Ändern
*    MODIFY ENTITIES OF z09_r_travel
*        ENTITY Travel
*        UPDATE FIELDS ( Description )
*        WITH VALUE #( ( AgencyId = c_agency_id TravelId = c_travel_id Description = 'Travel ongoing' ) )
*        FAILED failed.
*
*    out->write(  failed  ).

*    READ ENTITIES OF z09_r_travel
*        ENTITY z09_r_travel
*        ALL FIELDS WITH VALUE #( ( AgencyId = '070009' TravelId = '00004179' ) )
*        RESULT travels.
    travel-AgencyId = '070009'.
    travel-TravelId = '00004179'.
*    travel-Description = 'Travel ongoing'.
    travel-Description = travel-Description && '!'.
    APPEND travel TO travels.

    MODIFY ENTITIES OF z09_r_travel
        ENTITY Travel
        UPDATE FIELDS ( Description )
        WITH travels
        FAILED failed.

    out->write(  failed  ).


  ENDMETHOD.

ENDCLASS.
