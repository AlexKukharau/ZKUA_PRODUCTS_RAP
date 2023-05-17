@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Groups'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zkua_i_pg
  as select from zkua_d_prod_grup as ProductGroup
{
      @ObjectModel.text.element: ['Pgname']
  key pgid     as Pgid,
      pgname   as Pgname,
      imageurl as Imageurl
}
