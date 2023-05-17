@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface View for Currency'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zkua_i_currency
  as select from I_Currency as Currency
{
  key Currency,
      Decimals,
      CurrencyISOCode,
      AlternativeCurrencyKey,
      IsPrimaryCurrencyForISOCrcy,
      /* Associations */
      _Text
}
