CLASS zkua_cl_ve_imageurl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zkua_cl_ve_imageurl IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA MrktOrders TYPE STANDARD TABLE OF zkua_c_mrkt_ordr WITH DEFAULT KEY.
    MrktOrders = CORRESPONDING #( it_original_data ).

    LOOP AT MrktOrders ASSIGNING FIELD-SYMBOL(<MrktOrder>).
      <MrktOrder>-imageUrl = 'https://i7.pngguru.com/preview/423/632/57/computer-icons-purchase-order-order-fulfillment-purchasing-order-icon.jpg'.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( MrktOrders ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
