@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cyber Incident Header Root View'
define root view entity ZI_106_CYB_HDR
  as select from zz106_cyb_hdr
  
  
  composition [0..*] of ZI_106_CYB_ITM as _Logs 
{
  key inc_id      as IncidentID,
      inc_date    as IncidentDate,
      reporter    as Reporter,
      severity    as Severity,
      status      as Status,
      
      /* Expose the child connection (No comma here!) */
      _Logs
}
