@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Travel (Projection)'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z01_C_TRAVEL
  provider contract transactional_query as projection on Z01_R_TRAVEL
{
    key AgencyId,
    key TravelId,
    Description,
    CustomerId,
    BeginDate,
    EndDate,
    Status,
    ChangedAt,
    ChangedBy
}
