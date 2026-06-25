CLASS z05_cl_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z05_cl_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    CONSTANTS: c_agency_id TYPE /dmo/agency_id value '070005',
               c_travel_id type /dmo/travel_id VALUE '00004209'.

    DATA travels TYPE TABLE FOR UPDATE z05_r_travel.
    DATA travel TYPE STRUCTURE FOR UPDATE z05_r_travel.

    DATA failed TYPE RESPONSE FOR FAILED z05_r_travel.
    DATA failed_late TYPE RESPONSE FOR FAILED LATE z05_r_travel.

    DATA t_create TYPE TABLE FOR CREATE z05_r_travel.

    travel-AgencyId = c_agency_id.
    travel-TravelId = c_travel_id.
    travel-Description = 'new Description changed!'.
    APPEND travel TO travels.

    MODIFY ENTITIES OF z05_r_travel
      ENTITY Travel
      UPDATE
      FIELDS ( Description )
      WITH travels
      FAILED failed.


    out->write( failed ).

      COMMIT ENTITIES
      RESPONSE OF Z05_r_travel
        FAILED failed_late.


    out->write( failed_late ).

*    READ ENTITIES OF Z05_r_travel
*      ENTITY travel
*      ALL FIELDS WITH VALUE #(
*        ( AgencyId = '070000' TravelId = '00004144' )
*      )
*      RESULT DATA(t_travel)
*      FAILED failed.
*
*    out->write( t_travel ).

  ENDMETHOD.
ENDCLASS.
