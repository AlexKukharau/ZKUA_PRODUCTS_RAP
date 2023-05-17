CLASS lhc_Product DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF next_phase,
        no TYPE c LENGTH 1 VALUE '4', " invisible
      END OF next_phase.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Product RESULT result.

    METHODS makecopy FOR MODIFY
      IMPORTING keys FOR ACTION product~makecopy RESULT result.

    METHODS setfirstphase FOR DETERMINE ON SAVE
      IMPORTING keys FOR product~setfirstphase.

    METHODS validatepg FOR VALIDATE ON SAVE
      IMPORTING keys FOR product~validatepg.

    METHODS validateprodid FOR VALIDATE ON SAVE
      IMPORTING keys FOR product~validateprodid.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR product RESULT result.

    METHODS movetonextphase FOR MODIFY
      IMPORTING keys FOR ACTION product~movetonextphase RESULT result.

ENDCLASS.

CLASS lhc_Product IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD makecopy.

    DATA lt_create TYPE TABLE FOR CREATE zkua_i_product\\Product.

    DATA(lv_today) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_user)  = cl_abap_context_info=>get_user_alias( ).

    TRY.
        DATA(lv_produuid)  = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
    ENDTRY.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
      ENTITY Product
       ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(product_read_result)
    FAILED failed
    REPORTED reported.

    LOOP AT keys INTO DATA(key).
      DATA(lv_prodid) = key-%param.
    ENDLOOP.

    LOOP AT product_read_result ASSIGNING FIELD-SYMBOL(<product>).

      APPEND VALUE #( %cid     = keys[ 1 ]-%cid_ref
                      %data    = CORRESPONDING #( <product> EXCEPT ProdUuid Prodid ) )
        TO lt_create ASSIGNING FIELD-SYMBOL(<new_product>).

      <new_product>-ProdUuid = lv_produuid.
      <new_product>-Prodid = lv_prodid.
      <new_product>-Phaseid  = '1'.
      <new_product>-CreatedBy = lv_user.
      <new_product>-CreationTime = lv_today.
      <new_product>-ChangedBy = lv_user.
      <new_product>-ChangeTime = lv_today.

    ENDLOOP.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
      ENTITY Product
        CREATE FIELDS (
    ProdUuid
    Prodid
    Pgid
    Phaseid
    Height
    Depth
    Width
    SizeUom
    Price
    PriceCurrency
    Taxrate
    CreatedBy
    CreationTime
    ChangedBy
    ChangeTime )
          WITH lt_create

MAPPED mapped
FAILED DATA(failed_create)
REPORTED DATA(reported_create).

    result = VALUE #( FOR product IN lt_create INDEX INTO idx
    ( %tky = keys[ idx ]-%tky
    %param = CORRESPONDING #( product ) ) ) .


  ENDMETHOD.


  METHOD SetFirstPhase.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DELETE products WHERE Phaseid IS NOT INITIAL.
    CHECK products IS NOT INITIAL.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY Product
      UPDATE
        FROM VALUE #( FOR product IN products INDEX INTO i (
          %tky             = product-%tky
          Phaseid         = '1'
          %control-Phaseid = if_abap_behv=>mk-on ) )
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.


  METHOD ValidatePg.

    " Read relevant instance data
    READ ENTITIES OF zkua_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Pgid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DATA prodgrup TYPE SORTED TABLE OF zkua_d_prod_grup WITH UNIQUE KEY pgid.

    " Optimization of DB select: extract distinct non-initial ID
    prodgrup = CORRESPONDING #( products DISCARDING DUPLICATES MAPPING pgid = PgId EXCEPT * ).
    DELETE prodgrup WHERE pgid IS INITIAL.

    IF prodgrup IS NOT INITIAL.
      " Check if ID exist
      SELECT FROM zkua_d_prod_grup FIELDS pgid
        FOR ALL ENTRIES IN @prodgrup
        WHERE pgid = @prodgrup-pgid
        INTO TABLE @DATA(prodgrup_db).
    ENDIF.

    " Raise message for non existing and initial ID
    LOOP AT products INTO DATA(product).
      " Clear state messages that might exist
      APPEND VALUE #(  %tky               = product-%tky
                       %state_area        = 'VALIDATE_PG' )
        TO reported-product.

      IF product-Pgid IS INITIAL OR NOT line_exists( prodgrup_db[ pgid = product-Pgid ] ).
        APPEND VALUE #( %tky = product-%tky ) TO failed-product.

        APPEND VALUE #( %tky        = product-%tky
                        %state_area = 'VALIDATE_PG'
                        %msg        = NEW zcm_kua_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_kua_product=>pgname_unknown
                                          pgid = product-Pgid )
                        %element-Pgid = if_abap_behv=>mk-on )
          TO reported-product.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD ValidateProdid.

    " Read relevant instance data
    READ ENTITIES OF zkua_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Prodid ) WITH CORRESPONDING #( keys )
      RESULT DATA(products).

    DATA productid TYPE SORTED TABLE OF zkua_d_product WITH UNIQUE KEY prodid.

    " Optimization of DB select: extract distinct non-initial ID
    productid = CORRESPONDING #( products DISCARDING DUPLICATES MAPPING prodid = Prodid EXCEPT * ).
    DELETE productid WHERE prodid IS INITIAL.

    IF productid IS NOT INITIAL.
      " Check if ID exist
      SELECT FROM zkua_d_product FIELDS prodid
        FOR ALL ENTRIES IN @productid
        WHERE prodid = @productid-prodid
        INTO TABLE @DATA(productid_db).
    ENDIF.

    " Raise message for existing and initial ID
    LOOP AT products INTO DATA(product).
      " Clear state messages that might exist
      APPEND VALUE #(  %tky               = product-%tky
                       %state_area        = 'VALIDATE_PRODID' )
        TO reported-product.

      IF line_exists( productid_db[ prodid = product-Prodid ] ).
        APPEND VALUE #( %tky = product-%tky ) TO failed-product.

        APPEND VALUE #( %tky        = product-%tky
                        %state_area = 'VALIDATE_PRODID'
                        %msg        = NEW zcm_kua_product(
                                          severity = if_abap_behv_message=>severity-error
                                          textid   = zcm_kua_product=>duplicate_prodid
                                          prodid = product-Prodid )
                        %element-Prodid = if_abap_behv=>mk-on )
          TO reported-product.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
  ENTITY Product
    FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
  RESULT DATA(products)
  FAILED failed.

    result =
      VALUE #( FOR product IN products
          LET is_confirmed =   COND #( WHEN product-Phaseid = next_phase-no
                                      THEN if_abap_behv=>fc-o-disabled
                                      ELSE if_abap_behv=>fc-o-enabled  )
          IN
            ( %tky                 = product-%tky
              %action-MoveToNextPhase = is_confirmed
             ) ).

  ENDMETHOD.

  METHOD MoveToNextPhase.

    DATA: t_phase TYPE TABLE FOR UPDATE zkua_i_product\\Product.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
      ENTITY Product
        FIELDS ( Phaseid ) WITH CORRESPONDING #( keys )
      RESULT DATA(phases)
      FAILED failed
      REPORTED reported.

    LOOP AT phases ASSIGNING FIELD-SYMBOL(<ls_phase>).

      CASE <ls_phase>-Phaseid.

        WHEN 1.

          READ ENTITIES OF zkua_i_product IN LOCAL MODE
            ENTITY Product BY \_ProductMarket
              FIELDS ( Mrktid ProdUuid ) WITH CORRESPONDING #( keys )
            RESULT DATA(markets)
            FAILED failed.

          IF markets IS NOT INITIAL.
            <ls_phase>-Phaseid += 1.
          ELSE.
            APPEND VALUE #(  %tky = <ls_phase>-%tky ) TO failed-product.

            APPEND VALUE #(  %tky        = <ls_phase>-%tky
                             %state_area = 'NO_MARKETS'
                             %msg        = NEW zcm_kua_product(
                                               severity   = if_abap_behv_message=>severity-error
                                               textid     = zcm_kua_product=>no_markets )
                             %element-PhaseId = if_abap_behv=>mk-on
                              )
              TO reported-product.
          ENDIF.

        WHEN 2.

          READ ENTITIES OF zkua_i_product IN LOCAL MODE
            ENTITY Product BY \_ProductMarket
              FIELDS ( Status ) WITH CORRESPONDING #( keys )
            RESULT DATA(statuses)
            FAILED failed.

          LOOP AT statuses ASSIGNING FIELD-SYMBOL(<ls_status>).
            IF <ls_status>-status EQ 'X'.
              DATA(lv_status) = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF lv_status EQ 'X'.
            <ls_phase>-Phaseid += 1.
          ELSE.
            APPEND VALUE #(  %tky = <ls_phase>-%tky ) TO failed-product.

            APPEND VALUE #(  %tky        = <ls_phase>-%tky
                             %state_area = 'NO_CONFIRMS'
                             %msg        = NEW zcm_kua_product(
                                               severity   = if_abap_behv_message=>severity-error
                                               textid     = zcm_kua_product=>no_confirms )
                             %element-PhaseId = if_abap_behv=>mk-on
                              )
              TO reported-product.
          ENDIF.

        WHEN 3.

          READ ENTITIES OF zkua_i_product IN LOCAL MODE
            ENTITY Product BY \_ProductMarket
              FIELDS ( Enddate ) WITH CORRESPONDING #( keys )
            RESULT DATA(enddates)
            FAILED failed.

          DATA(lv_date) = cl_abap_context_info=>get_system_date( ).

          LOOP AT enddates ASSIGNING FIELD-SYMBOL(<ls_enddate>).
            IF <ls_enddate>-Enddate > lv_date.
              DATA(lv_enddate) = 'X'.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF lv_enddate NE 'X'.
            <ls_phase>-Phaseid += 1.
          ELSE.
            APPEND VALUE #(  %tky = <ls_phase>-%tky ) TO failed-product.

            APPEND VALUE #(  %tky        = <ls_phase>-%tky
                             %state_area = 'NO_END_DATE'
                             %msg        = NEW zcm_kua_product(
                                               severity   = if_abap_behv_message=>severity-error
                                               textid     = zcm_kua_product=>no_end_date )
                             %element-PhaseId = if_abap_behv=>mk-on
                              )
              TO reported-product.
          ENDIF.



      ENDCASE.

      APPEND VALUE #(
          %tky             = <ls_phase>-%tky
          PhaseID          = <ls_phase>-PhaseId
          %control-PhaseID = if_abap_behv=>mk-on ) TO t_phase.

    ENDLOOP.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
ENTITY Product
   UPDATE
     FIELDS ( PhaseId ) WITH t_phase.


    READ ENTITIES OF zkua_i_product IN LOCAL MODE
        ENTITY Product
    ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(products).

    result = VALUE #( FOR product IN products
                        ( %tky   = product-%tky
                          %param = product ) ).

  ENDMETHOD.

ENDCLASS.
