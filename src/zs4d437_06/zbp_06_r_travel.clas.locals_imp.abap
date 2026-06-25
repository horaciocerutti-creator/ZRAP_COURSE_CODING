CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.
    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.
    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.
    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check(
                                         i_agencyid = <result>-AgencyId
                                         i_actvt = '02' ).


      IF rc <> 0.
        <result>-%action-cancel_travel  = if_abap_behv=>auth-unauthorized.
        <result>-%update                = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel  = if_abap_behv=>auth-allowed.
        <result>-%update                = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
         ENTITY Travel
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-status <> 'C'.
        MODIFY ENTITIES OF z06_r_travel IN LOCAL MODE
          ENTITY Travel
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

    CONSTANTS c_area TYPE string VALUE `DESC`.
    READ ENTITIES OF z06_r_travel IN LOCAL MODE
         ENTITY Travel
            FIELDS ( Description )
            WITH CORRESPONDING #( keys )
            RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

        APPEND VALUE #( %tky = <travel>-%tky
         %state_area = c_area )
          TO reported-travel.

      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                          textid = /lrn/cm_s4d437=>field_empty
                        )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area          = c_area )
               TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.

    CONSTANTS c_area TYPE string VALUE `CUST`.

    READ ENTITIES OF z06_r_travel IN LOCAL MODE
       ENTITY Travel
          FIELDS ( CustomerId )
          WITH CORRESPONDING #( keys )
          RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

        APPEND VALUE #( %tky = <travel>-%tky
 %state_area = c_area )
TO reported-travel.


      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437(
                          textid = /lrn/cm_s4d437=>field_empty
                        )
                        %element-CustomerId = if_abap_behv=>mk-on
                        %state_area = c_area )
               TO reported-travel.
      ELSE.
        SELECT SINGLE FROM /dmo/i_customer FIELDS CustomerID
           WHERE CustomerID = @<travel>-CustomerId
           INTO @DATA(result).

        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky
                          %msg = NEW /lrn/cm_s4d437(
                            textid = /lrn/cm_s4d437=>customer_not_exist
                            customerid = <travel>-CustomerId
                          )
                          %element-CustomerId = if_abap_behv=>mk-on
                          %state_area = c_area )
                 TO reported-travel.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateBeginDate.

    CONSTANTS c_area TYPE string VALUE `BEGDATE`.

   READ ENTITIES OF Z06_R_Travel IN LOCAL MODE
   ENTITY Travel
   FIELDS ( BeginDate )
   WITH CORRESPONDING #( keys )
   RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

            APPEND VALUE #( %tky = <travel>-%tky
 %state_area = c_area )
TO reported-travel.

      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
        %msg = NEW /lrn/cm_s4d437(
        /lrn/cm_s4d437=>field_empty )
        %element-BeginDate = if_abap_behv=>mk-on
        %state_area = c_area )
        TO reported-travel.
      ELSEIF <travel>-begindate <
      cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
        %msg = NEW /lrn/cm_s4d437(
        /lrn/cm_s4d437=>begin_date_past )
        %element-Begindate = if_abap_behv=>mk-on
        %state_area = c_area )
        TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    CONSTANTS c_area TYPE string VALUE `ENDDATE`.

   READ ENTITIES OF Z06_R_Travel IN LOCAL MODE
   ENTITY Travel
   FIELDS ( EndDate )
   WITH CORRESPONDING #( keys )
   RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
        APPEND VALUE #( %tky = <travel>-%tky
 %state_area = c_area )
TO reported-travel.


      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
        %msg = NEW /lrn/cm_s4d437(
        /lrn/cm_s4d437=>field_empty )
        %element-EndDate = if_abap_behv=>mk-on
        %state_area = c_area )
        TO reported-travel.
      ELSEIF <travel>-EndDate <
      cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
        %msg = NEW /lrn/cm_s4d437(
        /lrn/cm_s4d437=>end_date_past )
        %element-EndDate = if_abap_behv=>mk-on
        %state_area = c_area )
        TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDateSequence.

    CONSTANTS c_area TYPE string VALUE `DATESEQ`.

   READ ENTITIES OF Z06_R_Travel IN LOCAL MODE
   ENTITY Travel
   FIELDS ( BeginDate EndDate )
   WITH CORRESPONDING #( keys )
   RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).

            APPEND VALUE #( %tky = <travel>-%tky
 %state_area = c_area )
TO reported-travel.

      IF <travel>-EndDate < <travel>-BeginDate.
        APPEND VALUE #( %tky = <travel>-%tky )
        TO failed-travel.

        APPEND VALUE #( %tky = <travel>-%tky
        %msg = NEW /lrn/cm_s4d437(
        /lrn/cm_s4d437=>flight_date_before_begin )
        %element = VALUE #(
        BeginDate = if_abap_behv=>mk-on
        EndDate = if_abap_behv=>mk-on )
        %state_area = c_area )
        TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  MEthod earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).
    mapped-travel = CORRESPONDING #( entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-AgencyId = agencyid.
      <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.


   ENDMETHOD.

  METHOD determineStatus.

    READ ENTITIES OF Z06_R_Travel IN LOCAL MODE
    ENTITY Travel
    FIELDS ( Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE status is not initial.
    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF z06_r_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR Travel IN travels (
            %tky = Travel-%tky
            Status = 'N' ) )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.

      READ ENTITIES OF z06_r_travel IN LOCAL MODE
          ENTITY Travel
             FIELDS ( Status BeginDate EndDate )
             WITH CORRESPONDING #( keys )
             RESULT DATA(travels).

      LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
        APPEND CORRESPONDING #( <travel> ) TO result
            ASSIGNING FIELD-SYMBOL(<result>).

        IF <travel>-Status = 'C' OR
            ( <travel>-EndDate IS NOT INITIAL AND <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).
          <result>-%update                  = if_abap_behv=>fc-o-disabled.
          <result>-%action-cancel_travel    = if_abap_behv=>fc-o-disabled.
        ELSE.
          <result>-%update                  = if_abap_behv=>fc-o-enabled.
          <result>-%action-cancel_travel    = if_abap_behv=>fc-o-enabled.
        ENDIF.

        IF <travel>-BeginDate IS NOT INITIAL AND
            <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).

          <result>-%field-CustomerId    = if_abap_behv=>fc-f-read_only.
          <result>-%field-BeginDate     = if_abap_behv=>fc-f-read_only.
        ELSE.
            <result>-%field-CustomerId    = if_abap_behv=>fc-f-mandatory.
            <result>-%field-BeginDate     = if_abap_behv=>fc-f-mandatory.
        ENDIF.
      ENDLOOP.

  ENDMETHOD.

ENDCLASS.
