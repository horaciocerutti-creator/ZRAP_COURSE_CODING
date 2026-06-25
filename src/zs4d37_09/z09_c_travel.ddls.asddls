@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption/Projection Vierw'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z09_C_TRAVEL 
provider contract transactional_query
as projection on Z09_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    Description,
    @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Customer_StdVH', element: 'CustomerID' } }]
    CustomerId,
    BeginDate,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy,
    LocChangedAt
}
