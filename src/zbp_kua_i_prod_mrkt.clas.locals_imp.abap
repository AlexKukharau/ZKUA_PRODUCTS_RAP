CLASS lhc_ProductMarket DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF confirm_status,
        yes TYPE c LENGTH 1 VALUE 'X', " confirmed
        no  TYPE c LENGTH 1 VALUE ' ', " doesn't confirmed
      END OF confirm_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ProductMarket RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ProductMarket RESULT result.

    METHODS Confirm FOR MODIFY
      IMPORTING keys FOR ACTION ProductMarket~Confirm RESULT result.

    METHODS CheckDuplicates FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~CheckDuplicates.

    METHODS ValidateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~ValidateEndDate.

    METHODS ValidateMarket FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~ValidateMarket.

    METHODS ValidateStartDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR ProductMarket~ValidateStartDate.
    METHODS set_iso_code FOR DETERMINE ON SAVE
      IMPORTING keys FOR ProductMarket~set_iso_code.

ENDCLASS.

CLASS lhc_productmarket IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY ProductMarket
      FIELDS ( Status ) WITH CORRESPONDING #( keys )
    RESULT DATA(markets)
    FAILED failed.

*    result =
*      VALUE #( FOR productmarket IN markets
*          LET is_confirmed =   COND #( WHEN productmarket-Status = confirm_status-yes
*                                      THEN if_abap_behv=>fc-o-disabled
*                                      ELSE if_abap_behv=>fc-o-enabled  )
*          IN
*            ( %tky                 = productmarket-%tky
*              %action-Confirm = is_confirmed
*             ) ).


    result = VALUE #( FOR productmarket IN markets
                ( %tky = productmarket-%tky
                  %features-%action-Confirm = COND #( WHEN productmarket-status = 'X'
                                                      THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
                  %assoc-_MarketOrder = COND #( WHEN productmarket-status = 'X'
                                                THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
 ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD Confirm.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY ProductMarket
       UPDATE
         FIELDS ( Status )
         WITH VALUE #( FOR key IN keys
                         ( %tky         = key-%tky
                           Status = confirm_status-yes ) )
    FAILED failed
    REPORTED reported.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY ProductMarket
      ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(markets).

    result = VALUE #( FOR ProductMarket IN markets
                        ( %tky   = productmarket-%tky
                          %param = productmarket ) ).

  ENDMETHOD.

  METHOD CheckDuplicates.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
   ENTITY ProductMarket
     FIELDS ( Mrktid ProdUuid ) WITH CORRESPONDING #( keys )
   RESULT DATA(markets).

    DATA prodmrkt TYPE SORTED TABLE OF zkua_d_prod_mrkt WITH UNIQUE KEY Mrktid.

    prodmrkt = CORRESPONDING #( markets DISCARDING DUPLICATES MAPPING Mrktid = Mrktid prod_uuid = ProdUuid EXCEPT * ).
    DELETE prodmrkt WHERE mrktid IS INITIAL.

    IF prodmrkt IS NOT INITIAL.

      SELECT FROM zkua_d_prod_mrkt
    FIELDS mrktid,
           prod_uuid
     FOR ALL ENTRIES IN @prodmrkt
     WHERE mrktid = @prodmrkt-mrktid
       AND prod_uuid = @prodmrkt-prod_uuid
     INTO TABLE @DATA(markets_db).
    ENDIF.

    LOOP AT markets INTO DATA(market).
      IF line_exists( markets_db[ mrktid = market-Mrktid
                            prod_uuid = market-ProdUuid ] ).
        APPEND VALUE #(  %tky = market-%tky ) TO failed-productmarket.

        APPEND VALUE #(  %tky        = market-%tky
                         %state_area = 'VALIDATE_MARKET'
                         %path       = VALUE #( Product-%is_draft = market-%is_draft
                                                Product-ProdUuid = market-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>duplicate_mrktid ) )
          TO reported-productmarket.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD ValidateEndDate.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY ProductMarket
      FIELDS ( Mrktid Startdate EndDate ProdUuid ) WITH CORRESPONDING #( keys )
    RESULT DATA(markets).

    LOOP AT markets INTO DATA(market).
      APPEND VALUE #(  %tky        = market-%tky
                       %state_area = 'VALIDATE_END_DATE' )
        TO reported-productmarket.

      IF market-Enddate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = market-%tky ) TO failed-productmarket.
        APPEND VALUE #(  %tky        = market-%tky
                         %state_area = 'VALIDATE_END_DATE'
                         %path       = VALUE #( Product-%is_draft = market-%is_draft
                                                Product-ProdUuid = market-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>wrong_end_date ) )
          TO reported-productmarket.
      ELSEIF market-EndDate < market-Startdate.
        APPEND VALUE #( %tky = market-%tky ) TO failed-productmarket.
        APPEND VALUE #(  %tky        = market-%tky
                         %state_area = 'VALIDATE_END_DATE'
                         %path       = VALUE #( Product-%is_draft = market-%is_draft
                                                Product-ProdUuid = market-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>wrong_end_to_start_date ) )
          TO reported-productmarket.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateMarket.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
       ENTITY ProductMarket
         FIELDS ( Mrktid ProdUuid ) WITH CORRESPONDING #( keys )
       RESULT DATA(prodmarkets).

    DATA markets TYPE SORTED TABLE OF zkua_d_market WITH UNIQUE KEY mrktid.

    markets = CORRESPONDING #( prodmarkets DISCARDING DUPLICATES MAPPING mrktid = Mrktid EXCEPT * ).
    DELETE markets WHERE mrktid IS INITIAL.

    IF markets IS NOT INITIAL.
      SELECT FROM zkua_d_market FIELDS mrktid
         FOR ALL ENTRIES IN @markets
         WHERE mrktid = @markets-mrktid
         INTO TABLE @DATA(markets_db).
    ENDIF.

    LOOP AT prodmarkets ASSIGNING FIELD-SYMBOL(<ls_prodmarket>).
      IF <ls_prodmarket>-Mrktid IS INITIAL OR NOT line_exists( markets_db[ mrktid = <ls_prodmarket>-Mrktid ] ).
        APPEND VALUE #(  %tky = <ls_prodmarket>-%tky ) TO failed-productmarket.
        APPEND VALUE #(  %tky        = <ls_prodmarket>-%tky
                         %state_area = 'VALIDATE_MARKETID'
                         %path       = VALUE #( Product-%is_draft = <ls_prodmarket>-%is_draft
                                                Product-ProdUuid = <ls_prodmarket>-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>market_unknown ) )
          TO reported-productmarket.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD ValidateStartDate.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
  ENTITY ProductMarket
    FIELDS ( Mrktid Startdate ProdUuid ) WITH CORRESPONDING #( keys )
  RESULT DATA(markets).

    LOOP AT markets INTO DATA(market).
      APPEND VALUE #(  %tky        = market-%tky
                       %state_area = 'VALIDATE_START_DATE' )
        TO reported-productmarket.

      IF market-Startdate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = market-%tky ) TO failed-productmarket.
        APPEND VALUE #(  %tky        = market-%tky
                         %state_area = 'VALIDATE_START_DATE'
                         %path       = VALUE #( Product-%is_draft = market-%is_draft
                                                Product-ProdUuid = market-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>wrong_start_date ) )
          TO reported-productmarket.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD set_iso_code.

*    READ ENTITIES OF zkua_i_product IN LOCAL MODE
*          ENTITY ProductMarket
*            FIELDS ( Mrktid ) WITH CORRESPONDING #( keys )
*          RESULT DATA(Markets).
*
*    LOOP AT Markets ASSIGNING FIELD-SYMBOL(<Market>).
*
*      SELECT SINGLE mrktname
*      FROM zkua_d_market
*        WHERE mrktid = @<Market>-Mrktid
*      INTO @DATA(MarketName).
*
*      TRY.
*          DATA(destination) = cl_soap_destination_provider=>create_by_url( i_url = 'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso' ).
*          DATA(proxy) = NEW zkua_co_country_info_service_s( destination = destination ).
*          DATA(request) = VALUE zkua_country_isocode_soap_requ( s_country_name = MarketName ).
*          proxy->country_isocode(
*            EXPORTING
*              input = request
*            IMPORTING
*              output = DATA(response)
*          ).
*
*          "handle response
*        CATCH cx_soap_destination_error.
*          "handle error
*        CATCH cx_ai_system_fault.
*          "handle error
*      ENDTRY.
*
*    ENDLOOP.
*
*   IF <Market>-IsoCode IS INITIAL AND response-country_isocode_result <> 'No country found by that name'.
*
*      MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
*        ENTITY ProductMarket
*          UPDATE FIELDS ( IsoCode ) WITH VALUE #(
*            FOR key IN keys ( %tky = <Market>-%tky
*                              IsoCode = response-country_isocode_result ) ).
*
*    ELSEIF response-country_isocode_result = 'No country found by that name'.
*
*      MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
*        ENTITY ProductMarket
*            UPDATE FIELDS ( IsoCode ) WITH VALUE #(
*                FOR key IN keys ( %tky = <Market>-%tky
*                                  IsoCode = space ) ).
*
*
*    ENDIF.

  ENDMETHOD.

ENDCLASS.
