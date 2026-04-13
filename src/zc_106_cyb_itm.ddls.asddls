@EndUserText.label: 'Projection View for Cyber Incident Logs'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: { headerInfo: { typeName: 'Action Log', typeNamePlural: 'Action Logs' } }
define view entity ZC_106_CYB_ITM
  as projection on ZI_106_CYB_ITM
{
      @UI.facet: [ { id: 'Log', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Log Details', position: 10 } ]
      
      @UI.identification: [ { position: 10 } ]
      @EndUserText.label: 'Incident ID'
  key IncidentID,

      @UI.lineItem: [ { position: 10 } ]
      @UI.identification: [ { position: 20 } ]
      @EndUserText.label: 'Log Position (e.g. 10, 20)'
  key LogPosition,

      @UI.lineItem: [ { position: 20 } ]
      @UI.identification: [ { position: 30 } ]
      @EndUserText.label: 'Action Date'
      ActionDate,

      @UI.lineItem: [ { position: 30 } ]
      @UI.identification: [ { position: 40 } ]
      @EndUserText.label: 'Description of Issue'
      Description,

      @UI.lineItem: [ { position: 40 } ]
      @UI.identification: [ { position: 50 } ]
      @EndUserText.label: 'Action Taken to Resolve'
      ActionTaken,

      /* Redirect back up to the parent */
      _Incident : redirected to parent ZC_106_CYB_HDR
}
