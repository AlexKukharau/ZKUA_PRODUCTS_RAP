@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View for Phase'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zkua_i_phase
  as select from zkua_d_phase as Phase
{
      @ObjectModel.text.element: ['Phase']
  key phaseid as Phaseid,
      phase   as Phase
}
