@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Market'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zkua_i_prod_mrkt
  as select from zkua_d_prod_mrkt as ProductMarket

  association        to parent zkua_i_product as _Product   on $projection.ProdUuid = _Product.ProdUuid
  composition [0..*] of zkua_i_mrkt_ordr      as _MarketOrder
  association [1..1] to zkua_i_market         as _Market    on $projection.Mrktid = _Market.Mrktid
  association [1..1] to zkua_i_order_aggr     as _OrderAggr on $projection.MrktUuid = _OrderAggr.MrktUuid

{
  key prod_uuid                   as ProdUuid,
  key mrkt_uuid                   as MrktUuid,
      mrktid                      as Mrktid,
      isocode                     as IsoCode,
      status                      as Status,
      case status
      when 'X'  then 3    -- 'yes'         | 3: green colour
      else  1               --             | 1: red colour
      end                         as StatusCriticality,
      startdate                   as Startdate,
      enddate                     as Enddate,

      _OrderAggr.TotalQuantity    as TotalQuantity,
      @Semantics.amount.currencyCode: 'Amountcurr'
      _OrderAggr.TotalNetamount   as TotalNetamount,
      @Semantics.amount.currencyCode: 'Amountcurr'
      _OrderAggr.TotalGrossamount as TotalGrossamount,
      _OrderAggr.Amountcurr       as Amountcurr,

      @Semantics.user.createdBy: true
      created_by                  as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      @Semantics.dateTime: true
      creation_time               as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by                  as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @Semantics.dateTime: true
      change_time                 as ChangeTime,

      _Product,
      _MarketOrder,
      _Market,
      _OrderAggr
}
