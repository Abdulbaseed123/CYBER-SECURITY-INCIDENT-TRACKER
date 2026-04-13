@EndUserText.label: 'Projection View for Cyber Incident Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@UI: { headerInfo: { typeName: 'Cyber Incident', typeNamePlural: 'Cyber Incidents' } }
@Search.searchable: true
define root view entity ZC_106_CYB_HDR
  provider contract transactional_query
  as projection on ZI_106_CYB_HDR
{
      @UI.facet: [ 
        { id: 'Header', purpose: #STANDARD, type: #IDENTIFICATION_REFERENCE, label: 'Incident Details', position: 10 },
        { id: 'Logs',   purpose: #STANDARD, type: #LINEITEM_REFERENCE,       label: 'Action Logs', position: 20, targetElement: '_Logs' } 
      ]
      
      @UI.lineItem: [ { position: 10 } ]
      @UI.identification: [ { position: 10 } ]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Incident ID'
  key IncidentID,

      @UI.lineItem: [ { position: 20 } ]
      @UI.identification: [ { position: 20 } ]
      @EndUserText.label: 'Date Reported'
      IncidentDate,

      @UI.lineItem: [ { position: 30 } ]
      @UI.identification: [ { position: 30 } ]
      @EndUserText.label: 'Reporter Name'
      Reporter,

      @UI.lineItem: [ { position: 40 } ]
      @UI.identification: [ { position: 40 } ]
      @EndUserText.label: 'Severity (HIGH, MED, LOW)'
      Severity,

      @UI.lineItem: [ { position: 50 } ]
      @UI.identification: [ { position: 50 } ]
      @EndUserText.label: 'Status (O=Open, C=Closed)'
      Status,

      /* Redirect down to the child */
      _Logs : redirected to composition child ZC_106_CYB_ITM
}
