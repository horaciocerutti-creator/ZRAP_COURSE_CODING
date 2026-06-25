CLASS zcl_06_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070006'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004203'.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_06_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.



    READ ENTITIES OF Z06_R_TRAVEL
      ENTITY TRAVEL
         ALL FIELDS WITH
            VALUE #(
                    (   TravelId = c_travel_id
                        AgencyId = c_agency_id ) )
         RESULT DATA(travels)
        FAILED DATA(failed).
    IF failed IS NOT INITIAL.
        out->write( failed ).
        RETURN.
    ENDIF.
    out->write( travels ).

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    "Siehe nochmal Aufgabe 4 Teil 2...

    MODIFY ENTITIES OF Z06_R_TRAVEL
      ENTITY TRAVEL
         UPDATE FIELDS ( Description )
           WITH VALUE #(
                    (   TravelId    = c_travel_id
                        AgencyId    = c_agency_id
                        Description = 'Changed again!' ) )
        FAILED DATA(failed_modify).

    IF failed_modify IS NOT INITIAL.
        out->write( failed_modify ).
        RETURN.
    ENDIF.
    COMMIT ENTITIES.
    out->write( 'Éntities succesfully updated.' ).

    READ ENTITIES OF Z06_R_TRAVEL
      ENTITY TRAVEL
         ALL FIELDS WITH
            VALUE #(
                    (   TravelId = c_travel_id
                        AgencyId = c_agency_id ) )
         RESULT DATA(travels_updated)
        FAILED DATA(failed_updated).
    IF failed_updated IS NOT INITIAL.
        out->write( failed_updated ).
        RETURN.
    ENDIF.
    out->write( travels_updated ).

  ENDMETHOD.
ENDCLASS.
