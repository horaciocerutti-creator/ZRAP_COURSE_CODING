CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    LOOP AT REsult assigning field-symbol(<result>).
        DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
            i_agencyid = <result>-agencyid
            i_actvt = '02'
        ).
        if rc <> 0.
          <result>-%update = if_abap_behv=>auth-unauthorized.
          <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        else.
          <result>-%update = if_abap_behv=>auth-allowed.
          <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        endif.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF Z02_R_Travel IN LOCAL MODE
         ENTITY Travel
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-status <> 'C'.
        MODIFY ENTITIES OF z02_r_travel IN LOCAL MODE
          ENTITY travel
          UPDATE FIELDS ( status )
          WITH VALUE #( ( %tky = travel-%tky
                              status = 'C' ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = new /LRN/CM_S4D437(
                          textid = /LRN/CM_S4D437=>already_canceled
                        ) )
               TO reported-travel.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
