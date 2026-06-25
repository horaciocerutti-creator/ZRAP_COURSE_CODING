CLASS zcl_08_eml DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070050'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004157'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_08_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF z08_r_travel
      ENTITY travel
      ALL FIELDS WITH VALUE #( ( AgencyId = c_agency_id
                                 TravelId = c_travel_id ) )
                                RESULT DATA(travels)
                                FAILED DATA(failed).

    IF failed IS NOT INITIAL.

      LOOP AT failed-travel REFERENCE INTO DATA(lr_failed_travel).
        out->write( lr_failed_travel->%fail-cause ).
        out->write( lr_failed_travel ).
      ENDLOOP.

    ELSE.

      LOOP AT travels REFERENCE INTO DATA(lr_travel).
        out->write( lr_travel->Description ).
      ENDLOOP.

      MODIFY ENTITIES OF z08_r_travel
        ENTITY travel
        UPDATE FIELDS ( Description ) WITH VALUE #( ( AgencyId    = c_agency_id
                                                      TravelId    = c_travel_id
                                                      Description = 'test My New Travel Description' ) )
                                                     " TODO: variable is assigned but never used (ABAP cleaner)
                                                     MAPPED DATA(mapped)
                                                     " TODO: variable is assigned but never used (ABAP cleaner)
                                                     FAILED DATA(failed_update)
                                                     " TODO: variable is assigned but never used (ABAP cleaner)
                                                     REPORTED DATA(reported).

      IF failed IS INITIAL.
        COMMIT ENTITIES.
        out->write( `Description successfully updated` ).
      ELSE.
        ROLLBACK ENTITIES.
        out->write( `Error updating the description` ).
      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
