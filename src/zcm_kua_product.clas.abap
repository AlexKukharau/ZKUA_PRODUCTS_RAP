CLASS zcm_kua_product DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message .

    CONSTANTS:
      BEGIN OF pgname_unknown,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'PGID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF pgname_unknown .
    CONSTANTS:
      BEGIN OF duplicate_prodid,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'PRODID',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF duplicate_prodid .
    CONSTANTS:
      BEGIN OF market_unknown,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF market_unknown .
    CONSTANTS:
      BEGIN OF wrong_start_date,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF wrong_start_date .
    CONSTANTS:
      BEGIN OF wrong_end_date,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF wrong_end_date .
    CONSTANTS:
      BEGIN OF wrong_end_to_start_date,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF wrong_end_to_start_date .
    CONSTANTS:
      BEGIN OF duplicate_mrktid,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF duplicate_mrktid .
    CONSTANTS:
      BEGIN OF no_markets,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_markets .
    CONSTANTS:
      BEGIN OF no_confirms,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '009',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_confirms .
    CONSTANTS:
      BEGIN OF no_end_date,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '010',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF no_end_date .
    CONSTANTS:
      BEGIN OF less_start_date,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '011',
        attr1 TYPE scx_attrname VALUE 'STARTDATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF less_start_date .
    CONSTANTS:
      BEGIN OF greater_end_date,
        msgid TYPE symsgid VALUE 'ZKUA_MSG',
        msgno TYPE symsgno VALUE '012',
        attr1 TYPE scx_attrname VALUE 'ENDDATE',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF greater_end_date .

    DATA pgid       TYPE zkua_pg_id READ-ONLY.
    DATA prodid     TYPE zkua_product_id READ-ONLY.
    DATA startdate  TYPE zkua_start_date READ-ONLY.
    DATA enddate    TYPE zkua_end_date READ-ONLY.

    METHODS constructor
      IMPORTING
        severity    TYPE if_abap_behv_message=>t_severity DEFAULT if_abap_behv_message=>severity-error
        textid      LIKE if_t100_message=>t100key OPTIONAL
        previous    TYPE REF TO cx_root OPTIONAL
        pgid        TYPE zkua_pg_id OPTIONAL
        prodid      TYPE zkua_product_id OPTIONAL
        startdate   TYPE zkua_start_date OPTIONAL
        enddate     TYPE zkua_end_date OPTIONAL.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcm_kua_product IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    CALL METHOD super->constructor
      EXPORTING
        previous = previous.
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->if_abap_behv_message~m_severity = severity.

    me->pgid        = pgid.
    me->prodid      = |{ prodid ALPHA = OUT }|.
    me->startdate   = startdate.
    me->enddate     = enddate.

  ENDMETHOD.
ENDCLASS.
