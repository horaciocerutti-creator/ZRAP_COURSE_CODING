@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Travel consumption view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z00_C_Travel
provider contract transactional_query
 as projection on Z00_R_TRAVEL
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
    Duration,
    ChangedAt,
    ChangedBy,
    LocChangedAt
}
