@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cyber Incident Log View'
define view entity ZI_106_CYB_ITM
  as select from zz106_cyb_itm
  
  
  association to parent ZI_106_CYB_HDR as _Incident 
    on $projection.IncidentID = _Incident.IncidentID
{
  key inc_id       as IncidentID,
  key log_pos      as LogPosition,
      action_date  as ActionDate,
      description  as Description,
      action_taken as ActionTaken,
      
      /* Expose the parent connection (No comma here!) */
      _Incident
}
