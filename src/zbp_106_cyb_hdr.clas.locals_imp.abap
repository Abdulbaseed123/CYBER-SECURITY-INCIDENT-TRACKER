" 1. THE TRANSACTIONAL BUFFER (Holds both Header and Item data)
CLASS lcl_buffer DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: mt_hdr_create TYPE STANDARD TABLE OF zz106_cyb_hdr,
                mt_hdr_delete TYPE STANDARD TABLE OF zz106_cyb_hdr-inc_id,
                mt_itm_create TYPE STANDARD TABLE OF zz106_cyb_itm,
                mt_itm_delete TYPE STANDARD TABLE OF zz106_cyb_itm.
ENDCLASS.

" 2. THE HEADER HANDLER
CLASS lhc_IncidentHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR IncidentHeader RESULT result.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE IncidentHeader.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE IncidentHeader.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE IncidentHeader.
    METHODS read FOR READ
      IMPORTING keys FOR READ IncidentHeader RESULT result.
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK IncidentHeader.

    " Create By Association: This handles child creation!
    METHODS cba_Logs FOR MODIFY
      IMPORTING entities_cba FOR CREATE IncidentHeader\_Logs.
ENDCLASS.

CLASS lhc_IncidentHeader IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    " Buffer the Header
    LOOP AT entities INTO DATA(ls_entity).
      APPEND VALUE #(
        inc_id   = ls_entity-IncidentID
        inc_date = ls_entity-IncidentDate
        reporter = ls_entity-Reporter
        severity = ls_entity-Severity
        status   = ls_entity-Status
      ) TO lcl_buffer=>mt_hdr_create.

      INSERT VALUE #( %cid = ls_entity-%cid  IncidentID = ls_entity-IncidentID ) INTO TABLE mapped-incidentheader.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Logs.
    " Buffer the Child Logs and link them to the Header
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        APPEND VALUE #(
          inc_id       = ls_cba-IncidentID  " The Parent ID!
          log_pos      = ls_target-LogPosition
          action_date  = ls_target-ActionDate
          description  = ls_target-Description
          action_taken = ls_target-ActionTaken
        ) TO lcl_buffer=>mt_itm_create.

        INSERT VALUE #( %cid = ls_target-%cid IncidentID = ls_cba-IncidentID LogPosition = ls_target-LogPosition ) INTO TABLE mapped-incidentlog.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND ls_key-IncidentID TO lcl_buffer=>mt_hdr_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

" 3. THE ITEM HANDLER (For updating/deleting existing logs)
CLASS lhc_IncidentLog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE IncidentLog.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE IncidentLog.
    METHODS read FOR READ
      IMPORTING keys FOR READ IncidentLog RESULT result.
ENDCLASS.

CLASS lhc_IncidentLog IMPLEMENTATION.
  METHOD update.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys INTO DATA(ls_key).
      APPEND VALUE #( inc_id = ls_key-IncidentID log_pos = ls_key-LogPosition ) TO lcl_buffer=>mt_itm_delete.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.
ENDCLASS.

" 4. THE SAVER CLASS (Executes all SQL Statements at the end)
CLASS lsc_ZI_106_CYB_HDR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_106_CYB_HDR IMPLEMENTATION.
  METHOD save.
    " 1. Insert Headers
    IF lcl_buffer=>mt_hdr_create IS NOT INITIAL.
      INSERT zz106_cyb_hdr FROM TABLE @lcl_buffer=>mt_hdr_create.
    ENDIF.

    " 2. Insert Items (Logs)
    IF lcl_buffer=>mt_itm_create IS NOT INITIAL.
      INSERT zz106_cyb_itm FROM TABLE @lcl_buffer=>mt_itm_create.
    ENDIF.

    " 3. Delete Items
    IF lcl_buffer=>mt_itm_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_itm_delete INTO DATA(ls_del_itm).
        DELETE FROM zz106_cyb_itm WHERE inc_id = @ls_del_itm-inc_id AND log_pos = @ls_del_itm-log_pos.
      ENDLOOP.
    ENDIF.

    " 4. Delete Headers
    IF lcl_buffer=>mt_hdr_delete IS NOT INITIAL.
      LOOP AT lcl_buffer=>mt_hdr_delete INTO DATA(lv_del_hdr).
        DELETE FROM zz106_cyb_hdr WHERE inc_id = @lv_del_hdr.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: lcl_buffer=>mt_hdr_create, lcl_buffer=>mt_hdr_delete,
           lcl_buffer=>mt_itm_create, lcl_buffer=>mt_itm_delete.
  ENDMETHOD.
ENDCLASS.
