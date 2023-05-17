@EndUserText.label: 'Product Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define root view entity zkua_c_product
  provider contract transactional_query
  as projection on zkua_i_product
{
  key ProdUuid,

      @Search.defaultSearchElement: true
      Prodid,

      @Consumption.valueHelpDefinition: [{ entity : {name: 'zkua_i_pg' , element: 'Pgid' } }]
      @ObjectModel.text.element: ['Pgname']
      @EndUserText.label: 'Page Group'
      @Search.defaultSearchElement: true
      Pgid,
      _ProductGroup.Pgname   as Pgname,

      @Consumption.valueHelpDefinition: [{ entity : {name: 'zkua_i_phase' , element: 'Phase' } }]
      @ObjectModel.text.element: ['Phase']
      @EndUserText.label: 'Phase'
      @Search.defaultSearchElement: true
      Phaseid,
      _Phase.Phase           as Phase,

      PhaseCriticality,

      Height,

      Depth,

      Width,

      @EndUserText.label: 'Size Dimensions'
      Dimension,

      @Consumption.valueHelpDefinition: [{ entity : {name: 'zkua_i_uom' , element: 'Msehi' } }]
      SizeUom,

      @EndUserText.label: 'Net Price'
      @Semantics.amount.currencyCode : 'PriceCurrency'
      Price,

      @Consumption.valueHelpDefinition: [{ entity : {name: 'zkua_i_currency' , element: 'Currency' } }]
      PriceCurrency,

      @EndUserText.label: 'Tax Rate'
      Taxrate,

      @Semantics.imageUrl: true
      _ProductGroup.Imageurl as ImageUrl,

      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,

      _ProductMarket : redirected to composition child zkua_c_prod_mrkt,
      _ProductGroup,
      _Phase,
      _Uom,
      _Currency
}
