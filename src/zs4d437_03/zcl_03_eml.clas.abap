CLASS zcl_03_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070003'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004148'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_03_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    READ ENTITIES OF z03_r_travel
        ENTITY z03_r_travel
        ALL FIELDS WITH
        VALUE #( ( AgencyId = c_agency_id
                   TravelId = c_travel_id ) )
                   RESULT DATA(lt_travel)
                   FAILED DATA(ls_failed).

    IF ls_failed IS INITIAL.
      out->write( lt_travel ).
      MODIFY ENTITIES OF Z03_R_Travel
         ENTITY Z03_R_Travel
          UPDATE FIELDS ( Description )
          WITH VALUE #( ( AgencyId = c_agency_id
                          TravelId = c_travel_id
                          Description = `New Description` ) )
          FAILED ls_failed.

      IF ls_failed IS INITIAL.
        COMMIT ENTITIES.
        out->write( `Update war erfolgreich` ).
      ELSE.
        ROLLBACK ENTITIES.
        out->write( `Fehler beim Update` ).
      ENDIF.
    ELSE.
      out->write( `Fehler beim Lesen der Reise` ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.

