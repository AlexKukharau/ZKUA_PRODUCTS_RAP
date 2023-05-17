@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Market Order'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zkua_i_mrkt_ordr
  as select from zkua_d_mrkt_ordr as MarketOrder

  association        to parent zkua_i_prod_mrkt as _ProductMarket on  $projection.MrktUuid = _ProductMarket.MrktUuid
                                                                  and $projection.ProdUuid = _ProductMarket.ProdUuid
  association [1..1] to zkua_i_product          as _Product       on  $projection.ProdUuid = _Product.ProdUuid
  association [1..1] to zkua_i_currency         as _Currency      on  $projection.Amountcurr = _Currency.Currency

{
  key prod_uuid        as ProdUuid,
  key mrkt_uuid        as MrktUuid,
  key order_uuid       as OrderUuid,
      orderid          as Orderid,
      quantity         as Quantity,
      calendar_year    as CalendarYear,
      delivery_date    as DeliveryDate,
      busspartner      as BussPartner,
      busspartnername  as BussPartnerName,
      busspartnergroup as BussPartnerGroup,
      @Semantics.amount.currencyCode : 'amountcurr'
      netamount        as Netamount,
      @Semantics.amount.currencyCode : 'amountcurr'
      grossamount      as Grossamount,
      amountcurr       as Amountcurr,
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      @Semantics.dateTime: true
      creation_time    as CreationTime,
      @Semantics.user.lastChangedBy: true
      changed_by       as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      @Semantics.dateTime: true
      change_time      as ChangeTime,

      _ProductMarket,
      _Product,
      _Currency
}
