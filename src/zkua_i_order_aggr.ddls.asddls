@AbapCatalog.sqlViewName: 'ZKUAIORDERAGGR'
@AbapCatalog.compiler.compareFilter: true
//@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggregated Data Entity for Market Order'
define view zkua_i_order_aggr
  as select from zkua_i_mrkt_ordr
{

  key MrktUuid,

      sum(Quantity)    as TotalQuantity,

      @Semantics.amount.currencyCode: 'Amountcurr'
      sum(Netamount)   as TotalNetamount,

      @Semantics.amount.currencyCode: 'Amountcurr'
      sum(Grossamount) as TotalGrossamount,

      Amountcurr

}
group by
  MrktUuid,
  Amountcurr
