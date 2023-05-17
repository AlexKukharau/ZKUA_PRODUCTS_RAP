@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product'

define root view entity zkua_i_product
  as select from zkua_d_product as Product

  composition [0..*] of zkua_i_prod_mrkt as _ProductMarket

  association [1..1] to zkua_i_pg        as _ProductGroup on $projection.Pgid = _ProductGroup.Pgid
  association [1..1] to zkua_i_phase     as _Phase        on $projection.Phaseid = _Phase.Phaseid
  association [1..1] to zkua_i_uom       as _Uom          on $projection.SizeUom = _Uom.Msehi
  association [1..1] to zkua_i_currency  as _Currency     on $projection.PriceCurrency = _Currency.Currency

{
  key prod_uuid                                                              as ProdUuid,
      prodid                                                                 as Prodid,
      pgid                                                                   as Pgid,
      phaseid                                                                as Phaseid,
      case phaseid
      when 1  then 1    -- 'plan'         | 1: red colour
      when 2  then 2    -- 'dev'          | 2: yellow colour
      when 3  then 3    -- 'prod'         | 3: green colour
      else 0            -- 'out'          | 0: unknown
      end                                                                    as PhaseCriticality,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      height                                                                 as Height,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      depth                                                                  as Depth,
      @Semantics.quantity.unitOfMeasure: 'SizeUom'
      width                                                                  as Width,
      concat_with_space(cast(height as abap.char(12)), (concat_with_space('x',
      (concat_with_space(cast(depth as abap.char(12)),
      concat_with_space ('x', cast(width as abap.char(12)), 1), 1)), 1)), 1) as Dimension,
      size_uom                                                               as SizeUom,
      @Semantics.amount.currencyCode : 'PriceCurrency'
      price                                                                  as Price,
      price_currency                                                         as PriceCurrency,
      taxrate                                                                as Taxrate,
      @Semantics.user.createdBy: true
      created_by                                                             as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      @Semantics.dateTime: true
      creation_time                                                          as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by                                                             as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @Semantics.dateTime: true
      change_time                                                            as ChangeTime,

      _ProductMarket,
      _ProductGroup,
      _Phase,
      _Uom,
      _Currency
}
