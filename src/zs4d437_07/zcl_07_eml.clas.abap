CLASS zcl_07_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070007'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004173'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_07_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF z07_r_travel
     ENTITY Travel ALL FIELDS
      WITH VALUE #( ( AgencyId = c_agency_id TravelId = c_travel_id ) )
    RESULT DATA(travels)
    FAILED DATA(failed).

    IF failed IS NOT INITIAL.
      out->write( `Error retrieving the travel` ).
    ELSE.
      MODIFY ENTITIES OF Z07_R_Travel ENTITY Travel
      UPDATE FIELDS ( Description )
      WITH VALUE #( ( AgencyId = c_agency_id TravelId = c_travel_id
      Description = `My new Description` ) )
      FAILED failed.
    ENDIF.

    IF failed IS INITIAL.
      COMMIT ENTITIES.
      out->write( `Description successfully updated` ).
    ELSE.
      ROLLBACK ENTITIES.
      out->write( `Error updating the description` ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
