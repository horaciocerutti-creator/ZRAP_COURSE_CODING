@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Demo root view entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z00_R_PA9999 as select from z00_pa9999
{
    key pernr as Pernr,
    key begda as Begda,
    key endda as Endda,
    last_name as LastName
}
