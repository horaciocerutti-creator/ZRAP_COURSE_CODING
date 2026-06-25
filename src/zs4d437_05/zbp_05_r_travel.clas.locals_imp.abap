CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF z05_r_Travel IN LOCAL MODE
           ENTITY Travel
              ALL FIELDS
              WITH CORRESPONDING #( keys )
              RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-status <> 'C'.
        MODIFY ENTITIES OF z05_r_travel IN LOCAL MODE
          ENTITY travel
          UPDATE FIELDS ( status )
          WITH VALUE #( ( %tky = travel-%tky
                              status = 'C' ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /lrn/cm_s4d437(
                          textid = /lrn/cm_s4d437=>already_canceled
                        ) )
               TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescription.

    READ ENTITIES OF z05_r_travel IN LOCAL MODE
  ENTITY travel
  FIELDS ( description )
  WITH CORRESPONDING #( keys )
  RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      IF <travel>-description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.


        APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                              /lrn/cm_s4d437=>field_empty
                              )

                          %element-description = if_abap_behv=>mk-on

                      )

                      TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).

      <mapping>-agencyid = agencyid.
      <mapping>-travelid = /lrn/cl_s4d437_model=>get_next_travelid( ).

    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF z05_r_travel IN LOCAL MODE
    ENTITY travel
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE Status IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF z05_r_travel IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN travels ( %tky = key-%tky
                                        Status = 'N' ) )

        REPORTED DATA(update_reported).


    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF z05_r_travel IN LOCAL MODE
ENTITY travel
FIELDS ( status begindate enddate )
WITH CORRESPONDING #( keys )
RESULT DATA(travels).



    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND CORRESPONDING #( <travel> ) TO result
      ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-status = 'C' OR
        ( <travel>-enddate IS NOT INITIAL AND
            <travel>-enddate < cl_abap_context_info=>get_system_date( )
        ).

        <result>-%update = if_abap_behv=>fc-o-disabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.

      ELSE.

        <result>-%update = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
