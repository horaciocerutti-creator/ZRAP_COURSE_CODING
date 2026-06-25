CLASS z00_cl_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z00_cl_eml IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA travels TYPE TABLE FOR UPDATE z00_r_travel.
    DATA travel TYPE STRUCTURE FOR UPDATE z00_r_travel.

    DATA failed TYPE RESPONSE FOR FAILED z00_r_travel.
    DATA failed_late TYPE RESPONSE FOR FAILED LATE z00_r_travel.

    DATA t_create TYPE TABLE FOR CREATE z00_r_travel.

    travel-AgencyId = '070000'.
    travel-TravelId = '00004143'.
    travel-Description = 'Travel in the Past!!!'.
    APPEND travel TO travels.

    MODIFY ENTITIES OF z00_r_travel
      ENTITY Travel
      UPDATE
      FIELDS ( Description )
      WITH travels
      FAILED failed.

    out->write( failed ).

    COMMIT ENTITIES
      RESPONSE OF Z00_r_travel
        FAILED failed_late.
    out->write( failed_late ).

    READ ENTITIES OF Z00_r_travel
      ENTITY travel
      ALL FIELDS WITH VALUE #(
        ( AgencyId = '070000' TravelId = '00004143' )
      )
      RESULT DATA(t_travel)
      FAILED failed.

    out->write( t_travel ).

  ENDMETHOD.
ENDCLASS.
