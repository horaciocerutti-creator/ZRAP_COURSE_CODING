CLASS zcl_01_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

    CONSTANTS c_agency_id TYPE /dmo/agency_id VALUE '070001'.
    CONSTANTS c_travel_id TYPE /dmo/travel_id VALUE '00004168'.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_01_EML IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA travels type table for read result z01_r_travel.
  DATA failedread TYPE RESPONSE FOR FAILED z01_r_travel.
  DATA failedmodify TYPE RESPONSE FOR FAILED z01_r_travel.

  READ ENTITIES OF Z01_R_Travel
    ENTITY Travel
        ALL FIELDS WITH VALUE #( ( AgencyId = c_agency_id
                                    TravelId = c_travel_id ) )
        RESULT travels
        FAILED failedread.

    IF failedread IS NOT INITIAL.

        out->write( `Error retrieving the travel` ).

    ELSE.

        out->write( `retrieving the travel` ).
        out->write( travels ).

    ENDIF.

    MODIFY ENTITIES OF Z01_R_Travel
        ENTITY Travel
         UPDATE FIELDS ( Description ) WITH VALUE #( ( AgencyId = c_agency_id
                                                     TravelId = c_travel_id
                                                     Description = 'My new Description5' ) )

        FAILED failedmodify.

         IF failedmodify IS NOT INITIAL.

            ROLLBACK ENTITIES.

            out->write( `Error modifying the travel` ).
            out->write( failedmodify ).

        ELSE.
            COMMIT ENTITIES.
            out->write( `Modifying the travel` ).

            READ ENTITIES OF Z01_R_Travel
            ENTITY Travel
                ALL FIELDS WITH VALUE #( ( AgencyId = c_agency_id
                                            TravelId = c_travel_id ) )
                RESULT travels
                FAILED failedread.

            IF failedread IS NOT INITIAL.

                out->write( `Error retrieving the travel` ).

            ELSE.

                out->write( `retrieving the travel` ).
                out->write( travels ).

            ENDIF.

        ENDIF.








  ENDMETHOD.
ENDCLASS.
