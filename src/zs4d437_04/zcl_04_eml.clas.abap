CLASS zcl_04_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070004'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004185'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_04_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    READ ENTITIES OF Z04_R_Travel
      ENTITY Travel04
        ALL FIELDS WITH VALUE #(  ( agencyid = c_agency_id travelid = c_travel_id ) )
        RESULT DATA(travels)
        FAILED DATA(failed).

    IF failed IS INITIAL.
      out->write( travels ).

      MODIFY ENTITIES OF z04_r_travel
        ENTITY travel04
          UPDATE
            FIELDS ( description )
            WITH VALUE #(  ( agencyid = c_agency_id travelid = c_travel_id description = 'Flo was here' ) )
            FAILED failed.

      IF failed IS INITIAL.
        COMMIT ENTITIES.
        out->write( 'Success' ).
      ELSE.
        ROLLBACK ENTITIES.
        out->write( 'Error' ).
      ENDIF.

    ELSE.
      out->write( 'Fehler' ).
    ENDIF.


  ENDMETHOD.
ENDCLASS.
