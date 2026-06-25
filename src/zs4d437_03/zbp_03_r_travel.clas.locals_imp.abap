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

    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.

    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
      DATA(rc) = /lrn/cl_s4d437_model=>authority_check( i_agencyid = <result>-AgencyId
                                                        i_actvt = '02' ).

      IF rc NE 0.
        <result>-%update = if_abap_behv=>auth-unauthorized.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%update = if_abap_behv=>auth-allowed.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    READ ENTITIES OF z03_r_travel IN LOCAL MODE " 'IN LOCAL MODE' = Keine Berechtigungsprüfung
    ENTITY travel
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-status NE 'C' AND travel-EndDate GT sy-datum.

        MODIFY ENTITIES OF z03_r_travel IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( status )
        WITH VALUE #(  (  %tky   = travel-%tky
                          status = 'C'        ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky
                         %msg = NEW /lrn/cm_s4d437( textid = /lrn/cm_s4d437=>already_canceled ) )
                         TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescription.

    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF Z03_R_TRavel IN LOCAL MODE
        ENTITY travel
        FIELDS ( Description )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-Description IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky
                        %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area          = c_area ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
     ENTITY Travel FIELDS ( BeginDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
        %element-BeginDate = if_abap_behv=>mk-on
        %state_area        = c_area ) TO reported-travel.
      ELSEIF <travel>-begindate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>begin_date_past )
        %element-Begindate = if_abap_behv=>mk-on
        %state_area        = c_area ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
        %element-CustomerId = if_abap_behv=>mk-on
        %state_area          = c_area ) TO reported-travel.
      ELSE.

        SELECT SINGLE Customerid FROM /dmo/i_customer
            WITH PRIVILEGED ACCESS
            WHERE CustomerID = @<travel>-CustomerId INTO @DATA(dummy).

        IF sy-subrc <> 0.
          APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( textid     = /lrn/cm_s4d437=>customer_not_exist
                                                                          customerid = <travel>-CustomerId )
          %element-CustomerId = if_abap_behv=>mk-on
          %state_area          = c_area ) TO reported-travel.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDateSequence.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
    ENTITY Travel FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-EndDate LT <travel>-BeginDate.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>dates_wrong_sequence )
        %element = VALUE #( BeginDate = if_abap_behv=>mk-on EndDate = if_abap_behv=>mk-on ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateEndDate.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
     ENTITY Travel FIELDS ( EndDate )
     WITH CORRESPONDING #( keys )
     RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      IF <travel>-EndDate IS INITIAL.
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
        %element-EndDate = if_abap_behv=>mk-on
        %state_area          = c_area ) TO reported-travel.
      ELSEIF <travel>-EndDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <travel>-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = <travel>-%tky %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>end_date_past )
        %element-EndDate = if_abap_behv=>mk-on
        %state_area      = c_area ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( ).
    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-AgencyId = agencyid.
      <mapping>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.
    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel FIELDS ( Status )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DELETE travels WHERE Status IS NOT INITIAL.

    CHECK travels IS NOT INITIAL. " Nur wenn Tabelle 'travels' nicht leer ist

    MODIFY ENTITIES OF Z03_R_Travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN travels ( %tky = key-%tky Status = 'N' ) )
        REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
      ENTITY Travel
      FIELDS ( Status BeginDate EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND CORRESPONDING #( <travel> ) TO result
      ASSIGNING FIELD-SYMBOL(<result>).

      IF <travel>-%is_draft = if_abap_behv=>mk-on.
        " Draft-Instanz lesen
        READ ENTITIES OF Z03_R_Travel IN LOCAL MODE
            ENTITY Travel FIELDS ( BeginDate EndDate )
            WITH VALUE #( ( %key = <travel>-%key ) )
            RESULT DATA(travels_active).

        " Im Draft darf das Beginndatum in der Vergangeheit liegt,
        " bei der echten Instanz nicht!
        IF travels_active IS NOT INITIAL.
          <travel>-BeginDate = travels_active[ 1 ]-BeginDate. " Datümer aus aktiven Insatnz übernehmen
          <travel>-EndDate = travels_active[ 1 ]-EndDate.
        ELSE.
          CLEAR <travel>-BeginDate.
          CLEAR <travel>-EndDate.
        ENDIF.
      ENDIF.

      IF <travel>-Status = 'C' OR
       ( <travel>-EndDate IS NOT INITIAL AND
         <travel>-EndDate < cl_abap_context_info=>get_system_date( ) ).
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
      ELSE.
        <result>-%update = if_abap_behv=>fc-o-enabled.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <travel>-BeginDate IS NOT INITIAL AND
         <travel>-BeginDate < cl_abap_context_info=>get_system_date( ).

        <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
