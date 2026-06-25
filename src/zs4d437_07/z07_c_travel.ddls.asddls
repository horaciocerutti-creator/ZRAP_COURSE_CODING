@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
root view entity Z07_C_TRAVEL
  provider contract transactional_query
  as projection on Z07_R_TRAVEL

{
  key AgencyId,
  key TravelId,
      @Search.defaultSearchElement: true
      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [
      { entity: {
                    name: '/DMO/I_Customer_StdVH', element: 'CustomerID'
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
