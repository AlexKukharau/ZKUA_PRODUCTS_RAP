@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Market'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zkua_i_market
  as select from zkua_d_market as Market
{
      @ObjectModel.text.element: ['Mrktname']
  key mrktid   as Mrktid,
      mrktname as Mrktname,
      code     as Code,
      imageurl as Imageurl
}
