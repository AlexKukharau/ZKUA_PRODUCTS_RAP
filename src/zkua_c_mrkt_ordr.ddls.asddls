@EndUserText.label: 'Market Order Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@Metadata.allowExtensions: true

define view entity zkua_c_mrkt_ordr
  as projection on zkua_i_mrkt_ordr as MarketOrder
{
  key     ProdUuid,
  key     MrktUuid,
  key     OrderUuid,

          @Search.defaultSearchElement: true
          @EndUserText.label: 'Order ID'
          Orderid,

          @Search.defaultSearchElement: true
          Quantity,

          @Search.defaultSearchElement: true
          @EndUserText.label: 'Year'
          CalendarYear,

          @Search.defaultSearchElement: true
          @EndUserText.label: 'Delivery Date'
          DeliveryDate,

          @ObjectModel.text.element: ['BussPartnerName']
          @EndUserText.label: 'Business Partner'
          BussPartner,
          BussPartnerName,

          @EndUserText.label: 'Business Partner Group'
          BussPartnerGroup,

          @Search.defaultSearchElement: true
          @EndUserText.label: 'Net Amount'
          Netamount,

          @Search.defaultSearchElement: true
          @EndUserText.label: 'Gross Amount'
          Grossamount,

          @Search.defaultSearchElement: true
          @Consumption.valueHelpDefinition: [{ entity : {name: 'zkua_i_currency' , element: 'Currency' } }]
          Amountcurr,

          @Semantics.imageUrl: true
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZKUA_CL_VE_IMAGEURL'
  virtual ImageUrl : abap.string( 256 ),

          CreatedBy,
          CreationTime,
          ChangedBy,
          ChangeTime,

          /* Associations */
          _Currency,
          _Product       : redirected to zkua_c_product,
          _ProductMarket : redirected to parent zkua_c_prod_mrkt
}
