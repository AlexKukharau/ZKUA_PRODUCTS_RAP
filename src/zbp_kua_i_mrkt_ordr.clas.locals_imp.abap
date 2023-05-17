CLASS lhc_MarketOrder DEFINITION INHERITING FROM cl_abap_behavior_handler.

PRIVATE SECTION.

    METHODS Calculate_Amount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR MarketOrder~Calculate_Amount.

    METHODS Calculate_Orderid FOR DETERMINE ON SAVE
      IMPORTING keys FOR MarketOrder~Calculate_Orderid.

    METHODS Set_Calendar_Year FOR DETERMINE ON SAVE
      IMPORTING keys FOR MarketOrder~Set_Calendar_Year.

    METHODS Validate_Delivery_Date FOR VALIDATE ON SAVE
      IMPORTING keys FOR MarketOrder~Validate_Delivery_Date.

ENDCLASS.

CLASS lhc_MarketOrder IMPLEMENTATION.

  METHOD Calculate_Amount.
  TYPES: BEGIN OF ty_amount_per_amountcurr,
             Netamount   TYPE zkua_netamount,
             Grossamount TYPE zkua_grossamount,
             Amountcurr  TYPE waers_curc,
           END OF ty_amount_per_amountcurr.

    DATA: amount_per_amountcurr TYPE TABLE FOR UPDATE zkua_i_product\\MarketOrder.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
          ENTITY Product
             FIELDS ( Price PriceCurrency Taxrate )
             WITH CORRESPONDING #( keys )
          RESULT DATA(prices).

    LOOP AT prices ASSIGNING FIELD-SYMBOL(<price>).

      READ ENTITIES OF zkua_i_product IN LOCAL MODE
         ENTITY MarketOrder
            FIELDS ( Quantity )
            WITH CORRESPONDING #( keys )
         RESULT DATA(orders).

      LOOP AT orders ASSIGNING FIELD-SYMBOL(<order>).

        APPEND VALUE #(
               %tky         = <order>-%tky
               Netamount    = <price>-Price * <order>-Quantity
               Grossamount  = <price>-Price * <order>-Quantity + <price>-Price *
                              <order>-Quantity * <price>-Taxrate / 100
               Amountcurr   = <price>-PriceCurrency
             )    TO amount_per_amountcurr.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
           ENTITY MarketOrder
             UPDATE FIELDS ( Netamount
                             Grossamount
                             Amountcurr ) WITH amount_per_amountcurr
             REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).


  ENDMETHOD.

  METHOD Calculate_Orderid.

      DATA max_orderid TYPE zkua_order_id.
    DATA update TYPE TABLE FOR UPDATE zkua_i_product\\MarketOrder.

    READ ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY MarketOrder BY \_ProductMarket
      FIELDS ( MrktUuid )
      WITH CORRESPONDING #( keys )
      RESULT DATA(markets).

    LOOP AT markets INTO DATA(market).
      READ ENTITIES OF zkua_i_product IN LOCAL MODE
        ENTITY ProductMarket BY \_MarketOrder
          FIELDS ( OrderID )
        WITH VALUE #( ( %tky = market-%tky ) )
        RESULT DATA(orders).

      max_orderid = '0'.
      LOOP AT orders INTO DATA(order).
        IF order-Orderid > max_orderid.
          max_orderid = order-Orderid.
        ENDIF.
      ENDLOOP.

      LOOP AT orders INTO order WHERE Orderid IS INITIAL.
        max_orderid += 1.
        APPEND VALUE #( %tky      = order-%tky
                        Orderid = max_orderid
                      ) TO update.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY MarketOrder
      UPDATE FIELDS ( Orderid ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD Set_Calendar_Year.

  DATA update TYPE TABLE FOR UPDATE zkua_i_product\\MarketOrder.


    READ ENTITIES OF zkua_i_product IN LOCAL MODE
        ENTITY MarketOrder BY \_ProductMarket
          FIELDS ( MrktUuid )
          WITH CORRESPONDING #( keys )
          RESULT DATA(markets).

    LOOP AT markets INTO DATA(market).
      READ ENTITIES OF zkua_i_product IN LOCAL MODE
        ENTITY ProductMarket BY \_MarketOrder
          FIELDS ( DeliveryDate CalendarYear )
        WITH VALUE #( ( %tky = market-%tky ) )
        RESULT DATA(dates).

      LOOP AT dates INTO DATA(date) WHERE DeliveryDate IS NOT INITIAL AND CalendarYear IS INITIAL.
        APPEND VALUE #( %tky = date-%tky
                        CalendarYear = date-DeliveryDate+0(4) ) TO update.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zkua_i_product IN LOCAL MODE
    ENTITY MarketOrder
      UPDATE FIELDS ( CalendarYear ) WITH update
    REPORTED DATA(update_reported).

    reported = CORRESPONDING #( DEEP update_reported ).

  ENDMETHOD.

  METHOD Validate_Delivery_Date.

  READ ENTITIES OF zkua_i_product IN LOCAL MODE
  ENTITY ProductMarket
    FIELDS ( Startdate Enddate ) WITH CORRESPONDING #( keys )
  RESULT DATA(marketdates).

    LOOP AT marketdates INTO DATA(marketdate).
    READ ENTITIES OF zkua_i_product IN LOCAL MODE
  ENTITY ProductMarket BY \_MarketOrder
    FIELDS ( DeliveryDate ) WITH VALUE #( ( %tky = marketdate-%tky ) )
  RESULT DATA(orderdates).

  LOOP AT orderdates INTO DATA(orderdate).

      APPEND VALUE #(  %tky        = orderdate-%tky
                       %state_area = 'VALIDATE_DELIVERY_DATE' )
        TO reported-marketorder.

      IF orderdate-DeliveryDate < marketdate-Startdate OR orderdate-DeliveryDate = marketdate-Startdate.
        APPEND VALUE #( %tky = orderdate-%tky ) TO failed-marketorder.
        APPEND VALUE #(  %tky        = orderdate-%tky
                         %state_area = 'VALIDATE_DELIVERY_DATE'
                         %path       = VALUE #( Product-%is_draft = orderdate-%is_draft
                                                ProductMarket-%is_draft = orderdate-%is_draft
                                                Product-ProdUuid = orderdate-ProdUuid
                                                ProductMarket-ProdUuid = orderdate-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>less_start_date
                                           startdate = marketdate-Startdate )
                         %element-DeliveryDate = if_abap_behv=>mk-on )
          TO reported-marketorder.

          ELSEIF orderdate-DeliveryDate > marketdate-Enddate.
        APPEND VALUE #( %tky = orderdate-%tky ) TO failed-marketorder.
        APPEND VALUE #(  %tky        = orderdate-%tky
                         %state_area = 'VALIDATE_DELIVERY_DATE'
                         %path       = VALUE #( Product-%is_draft = orderdate-%is_draft
                                                ProductMarket-%is_draft = orderdate-%is_draft
                                                Product-ProdUuid = orderdate-ProdUuid
                                                ProductMarket-ProdUuid = orderdate-ProdUuid )
                         %msg        = NEW zcm_kua_product(
                                           severity   = if_abap_behv_message=>severity-error
                                           textid     = zcm_kua_product=>greater_end_date
                                           enddate = marketdate-Enddate )
                         %element-DeliveryDate = if_abap_behv=>mk-on )
          TO reported-marketorder.

      ENDIF.
    ENDLOOP.
   ENDLOOP.
  ENDMETHOD.

ENDCLASS.
