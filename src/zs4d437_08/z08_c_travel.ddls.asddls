@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Z08_C_TRAVEL'
@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: false

define root view entity Z08_C_TRAVEL
provider contract transactional_query
  as projection on Z08_R_TRAVEL

{
  key AgencyId,
  key TravelId,

      Description,
      CustomerId,
      BeginDate,
      EndDate,
      Status,
      ChangedAt,
      ChangedBy,

      LocChangedAt
}
