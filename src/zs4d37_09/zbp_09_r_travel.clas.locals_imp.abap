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
    METHODS validateCustomerId FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomerId.
    METHODS determineStatus FOR DETERMINE ON SAVE
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
    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
            ALL FIELDS
            WITH CORRESPONDING #(  keys )
            RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      IF travel-Status <> 'C'.
        MODIFY ENTITIES OF z09_r_travel IN LOCAL MODE
          ENTITY Travel
          UPDATE FIELDS ( Status )
          WITH VALUE #( ( %tky = travel-%tky
                          Status = 'C' ) ).
      ELSE.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /lrn/cm_s4d437(
                          textid = /lrn/cm_s4d437=>already_canceled
                        ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateDescription.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF z09_r_travel
        ENTITY Travel
            FIELDS ( Description )
            WITH CORRESPONDING #(  keys )
            RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
        " Message löschen!
      APPEND VALUE #(  %tky = travel-%tky
                                 %state_area = c_area
                               ) TO reported-travel.
      IF travel-Description IS INITIAL.
        APPEND VALUE #(  %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky
                          %msg = NEW /lrn/cm_s4d437(
                            textid = /lrn/cm_s4d437=>field_empty
                            )
                            %element-Description = if_abap_behv=>mk-on
                            " Area angeben
                            %state_area = c_area
                          ) TO reported-travel.
      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateCustomerId.
    CONSTANTS c_area TYPE string VALUE `DESC`.

    READ ENTITIES OF z09_r_travel
        ENTITY Travel
            FIELDS ( CustomerId )
            WITH CORRESPONDING #(  keys )
            RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
        " Message löschen!
      APPEND VALUE #(  %tky = travel-%tky
                                 %state_area = c_area
                               ) TO reported-travel.
      IF travel-CustomerId IS INITIAL.
        APPEND VALUE #(  %tky = travel-%tky ) TO failed-travel.
        APPEND VALUE #(  %tky = travel-%tky
                          %msg = NEW /lrn/cm_s4d437(
                            textid = /lrn/cm_s4d437=>field_empty
                            )
                            %element-CustomerId = if_abap_behv=>mk-on
                            %state_area = c_area
                          ) TO reported-travel.
      ELSE.
        SELECT CustomerId
        FROM /DMO/I_Customer WITH PRIVILEGED ACCESS
        WHERE CustomerID = @travel-CustomerId
        INTO TABLE @DATA(customersFound).

        IF sy-subrc <> 0.
          APPEND VALUE #(  %tky = travel-%tky ) TO failed-travel.
          APPEND VALUE #(  %tky = travel-%tky
                        %msg = NEW /lrn/cm_s4d437(
                          textid = /lrn/cm_s4d437=>customer_not_exist
                          customerid = travel-CustomerId
                          )
                          %element-CustomerId = if_abap_behv=>mk-on
                          %state_area = c_area
                        ) TO reported-travel.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = /lrn/cl_s4d437_model=>get_agency_by_user( sy-uname ).
    mapped-travel = CORRESPONDING #( entities ).
    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<entity>).
      <entity>-AgencyID = agencyid.
      <entity>-TravelId = /lrn/cl_s4d437_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD determineStatus.
    READ ENTITIES OF z09_r_travel IN LOCAL MODE
         ENTITY Travel
            FIELDS ( Status )
            WITH CORRESPONDING #(  keys )
            RESULT DATA(travels).

    DELETE travels WHERE status IS NOT INITIAL.

    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF z09_r_travel IN LOCAL MODE
        ENTITY Travel
        UPDATE FIELDS (  status )
        WITH VALUE #(  FOR travel IN travels (  %tky = travel-%tky status = 'N' ) )
        REPORTED DATA(updateReported).

    reported = CORRESPONDING #( DEEP updateReported ).
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF z09_r_travel IN LOCAL MODE
       ENTITY travel
          FIELDS ( status beginDate EndDate )
          WITH CORRESPONDING #(  keys  )
          RESULT DATA(travels).

    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      APPEND CORRESPONDING #( <travel> ) TO result
          ASSIGNING FIELD-SYMBOL(<result>).
      IF <travel>-status = 'C' OR
       ( <travel>-enddate IS NOT INITIAL AND
         <travel>-enddate < sy-datum ).
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.
        <result>-%update = if_abap_behv=>fc-o-disabled.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
        <result>-%update = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <travel>-begindate IS NOT INITIAL AND
         <travel>-begindate < sy-datum.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-read_only.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-read_only.
      ELSE.
        <result>-%field-CustomerId = if_abap_behv=>fc-f-mandatory.
        <result>-%field-BeginDate = if_abap_behv=>fc-f-mandatory.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
