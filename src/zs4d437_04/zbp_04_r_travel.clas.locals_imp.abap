CLASS lhc_Travel04 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel04 RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel04 RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel04~cancel_travel.
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel04~validateDescription.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel04~validateCustomer.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel04~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel04 RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel04.

ENDCLASS.

CLASS lhc_Travel04 IMPLEMENTATION.

  METHOD get_instance_authorizations.

    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      DATA(rc) = /LRN/CL_S4d437_model=>authority_check( i_agencyid = <result>-agencyid
                                                        i_actvt = '02' ).

      IF rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update = if_abap_behv=>auth-unauthorized.

      ENDIF.
    ENDLOOP.



  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
        ENTITY Travel04
           ALL FIELDS WITH CORRESPONDING #( keys )
           RESULT DATA(travel).

    LOOP AT travel INTO DATA(ls_travel).
      IF ls_travel-status <> 'C'.

        MODIFY ENTITIES OF z04_r_travel IN LOCAL MODE
          ENTITY Travel04
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( %tky = ls_travel-%tky
                          Status = 'C' ) )
          FAILED failed
          REPORTED reported.
      ELSE.
        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-travel04.
        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW /lrn/cm_s4d437(
                          textid = /lrn/cm_s4d437=>already_canceled
                        ) )
               TO reported-travel04.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.



  METHOD validateDescription.
    CONSTANTS c_area TYPE string VALUE `DESC`.
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
          ENTITY Travel04
             FIELDS ( Description )
             WITH CORRESPONDING #( keys )
             RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                         %state_area = c_area
                        )
             TO reported-travel04.

      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel04.
        APPEND VALUE #( %tky = <travel>-%tky
                  %msg = NEW /lrn/cm_s4d437(
                             /lrn/cm_s4d437=>field_empty
                           )
                  %element-description = if_abap_behv=>mk-on
                  %state_area = c_area
                )
      TO reported-travel04.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
    CONSTANTS c_area TYPE string VALUE `CUST`.
    READ ENTITIES OF z04_r_travel IN LOCAL MODE
   ENTITY travel04
   FIELDS ( customerid )
   WITH CORRESPONDING #( keys )
   RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND VALUE #( %tky = <travel>-%tky
                   %state_area = c_area
                 )
       TO reported-travel04.
      IF <travel>-customerid IS INITIAL.

        APPEND VALUE #( %tky = <travel>-%tky )
       TO failed-travel04.
        APPEND VALUE #( %tky = <travel>-%tky
                 %msg = NEW /lrn/cm_s4d437(
                            /lrn/cm_s4d437=>field_empty
                          )
                 %element-customerid = if_abap_behv=>mk-on
                 %state_area = c_area
               )
     TO reported-travel04.


      ELSE.

        SELECT SINGLE FROM /dmo/i_customer FIELDS customerid WHERE customerid = @<travel>-customerid INTO @DATA(dummy).

        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel04.
          APPEND VALUE #( %tky = <travel>-%tky
                  %msg = NEW /lrn/cm_s4d437(
                               textid     = /lrn/cm_s4d437=>customer_not_exist
                               customerid = <travel>-customerid
                            )
                   %element-customerid = if_abap_behv=>mk-on
                   %state_area = c_area
                )
      TO reported-travel04.

        ENDIF.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).
    mapped-travel04 = CORRESPONDING #( entities ).
    LOOP AT mapped-travel04 ASSIGNING FIELD-SYMBOL(<mapped>).
      <mapped>-agencyid = agencyid.
      <mapped>-travelid = /lrn/cl_s4d437_model=>get_next_travelid( ).

    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF z04_r_travel IN LOCAL MODE
            ENTITY travel04
               FIELDS ( status )
               WITH CORRESPONDING #( keys )
               RESULT DATA(travels).

    DELETE travels WHERE Status IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF Z04_R_Travel IN LOCAL MODE
    ENTITY Travel04
      UPDATE FIELDS ( Status )
      WITH VALUE #( FOR key IN travels ( %tky   = key-%tky
                                         Status = 'N' )  )
      REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF Z04_R_TRAVEL IN LOCAL MODE
    ENTITY travel04
    FIELDS ( status begindate enddate changedby )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

      APPEND CORRESPONDING #( <travel> ) TO result
                 ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-%is_draft = if_abap_behv=>mk-on. " Special Handling for Drafts
        " Try to Read BeginDate and EndDate from active instance
        READ ENTITIES OF Z04_R_TRAVEL IN LOCAL MODE
        ENTITY travel04
          FIELDS ( begindate enddate )
          WITH VALUE #( ( %key = <travel>-%key
                          %is_draft = if_abap_behv=>mk-off   "optional
                      ) )
          RESULT DATA(travels_activ).
        IF travels_activ IS NOT INITIAL.
          " edit draft (active instance exists)
          " use BeginDate and EndDate in active instance for feature control
          <travel>-begindate = travels_activ[ 1 ]-begindate.
          <travel>-enddate   = travels_activ[ 1 ]-enddate.
        ELSE.
          " new draft - use initial values for feature control.
          CLEAR <travel>-begindate.
          CLEAR <travel>-enddate.
        ENDIF.
      ENDIF.

      IF <travel>-status = 'C' OR
         ( <travel>-enddate IS NOT INITIAL AND
           <travel>-enddate < cl_abap_context_info=>get_system_date( )
         ).

        <result>-%update               = if_abap_behv=>fc-o-disabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.

      ELSE.

        <result>-%update               = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.

      ENDIF.

      IF <travel>-begindate IS NOT INITIAL AND
         <travel>-begindate < cl_abap_context_info=>get_system_date( ).

        <result>-%field-customerid = if_abap_behv=>fc-f-read_only.
        <result>-%field-begindate  = if_abap_behv=>fc-f-read_only.

      ELSE.

        <result>-%field-customerid = if_abap_behv=>fc-f-mandatory.
        <result>-%field-begindate  = if_abap_behv=>fc-f-mandatory.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
