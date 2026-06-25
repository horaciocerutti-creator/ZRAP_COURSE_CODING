@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z05_C_TRAVEL
  provider contract transactional_query
  as projection on Z05_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition:
          [ {entity:
              { name: '/DMO/I_Customer_StdVH',
              element: 'CustomerID'
              }
            }
          ]
      CustomerId,
      BeginDate,
      EndDate,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt
}
