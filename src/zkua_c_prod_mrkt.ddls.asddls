@EndUserText.label: 'Product Market Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity zkua_c_prod_mrkt
  as projection on zkua_i_prod_mrkt as ProductMarket
{
  key ProdUuid,

  key MrktUuid,

      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{entity : {name: 'zkua_i_market', element: 'Mrktid' } }]
      @ObjectModel.text.element: ['Mrktname']
      @EndUserText.label: 'Market:'
      Mrktid,
      _Market.Mrktname,

      @EndUserText.label: 'ISO-Code'
      IsoCode,

      @EndUserText.label: 'Confirmed?'
      Status,

      StatusCriticality,

      @EndUserText.label: 'Start Date'
      Startdate,

      @EndUserText.label: 'End Date'
      Enddate,

      @Semantics.imageUrl: true
      _Market.Imageurl as ImageUrl,

      @EndUserText.label: 'Total Quantity'
      TotalQuantity,

      @EndUserText.label: 'Total Net Amount'
      TotalNetamount,

      @EndUserText.label: 'Total Gross Amount'
      TotalGrossamount,

      Amountcurr,


      CreatedBy,
      CreationTime,
      ChangedBy,
      ChangeTime,

      /* Associations */
      _Market,
      _MarketOrder : redirected to composition child zkua_c_mrkt_ordr,
      _Product     : redirected to parent zkua_c_product
}
