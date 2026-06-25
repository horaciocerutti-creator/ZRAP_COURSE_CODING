@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Travel C'
@Metadata.allowExtensions: true
define root view entity Z04_C_Travel
  provider contract transactional_query
  as projection on Z04_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      Description,
    @Consumption.valueHelpDefinition: [ { entity:
 { name: '/DMO/I_Customer_StdVH',
 element: 'CustomerID'
 }
 } ]
      CustomerId,
      BeginDate,
      EndDate,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt
}
