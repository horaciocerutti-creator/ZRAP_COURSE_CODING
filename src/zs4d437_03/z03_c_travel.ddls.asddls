@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Travel Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity Z03_C_Travel 
provider contract transactional_query
  as projection on Z03_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    Description,
    
    @Consumption.valueHelpDefinition: [{ 
        entity: {
            name: '/DMO/I_Customer_StdVH',
            element: 'CustomerID'
        }
     }]
    CustomerId,
    BeginDate,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt
}
