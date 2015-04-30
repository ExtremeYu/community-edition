--
-- Title:      Upgraded Activiti tables to 5.10 version
-- Database:   Oracle
-- Since:      V4.1 Schema 5115
-- Author:     Frederik Heremans
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- Upgraded Activiti tables to 5.10 version

--
-- Upgrade scripts for 5.8 to 5.9
--

alter table ACT_RU_EXECUTION 
add SUSPENSION_STATE_ INTEGER;

alter table ACT_RE_PROCDEF
add SUSPENSION_STATE_ INTEGER;

alter table ACT_RE_PROCDEF
add REV_ INTEGER;

update ACT_RE_PROCDEF set REV_ = 1;
update ACT_RE_PROCDEF set SUSPENSION_STATE_ = 1;
update ACT_RU_EXECUTION set SUSPENSION_STATE_ = 1;

create table ACT_RU_EVENT_SUBSCR (
    ID_ NVARCHAR2(64) not null,
    REV_ integer,
    EVENT_TYPE_ NVARCHAR2(255) not null,
    EVENT_NAME_ NVARCHAR2(255),
    EXECUTION_ID_ NVARCHAR2(64),
    PROC_INST_ID_ NVARCHAR2(64),
    ACTIVITY_ID_ NVARCHAR2(64),
    CONFIGURATION_ NVARCHAR2(255),
    CREATED_ TIMESTAMP(6) not null,
    primary key (ID_)
);

create index ACT_IDX_EVENT_SUBSCR_CONFIG_ on ACT_RU_EVENT_SUBSCR(CONFIGURATION_);

create index ACT_IDX_EVENT_SUBSCR on ACT_RU_EVENT_SUBSCR(EXECUTION_ID_);
alter table ACT_RU_EVENT_SUBSCR
    add constraint ACT_FK_EVENT_EXEC
    foreign key (EXECUTION_ID_)
    references ACT_RU_EXECUTION(ID_);
    
alter table ACT_RU_EXECUTION 
add IS_EVENT_SCOPE_ NUMBER(1,0) CHECK (IS_EVENT_SCOPE_ IN (1,0));

update ACT_RU_EXECUTION set IS_EVENT_SCOPE_ = 0;

alter table ACT_HI_PROCINST
add DELETE_REASON_ NVARCHAR2(2000);

alter table ACT_GE_BYTEARRAY 
add GENERATED_ NUMBER(1,0) CHECK (GENERATED_ IN (1,0));

update ACT_GE_BYTEARRAY set GENERATED_ = 0;

--
-- Upgrade scripts for 5.9 to 5.10
--

alter table ACT_RU_IDENTITYLINK
add PROC_DEF_ID_ NVARCHAR2(64);

create index ACT_IDX_ATHRZ_PROCEDEF  on ACT_RU_IDENTITYLINK(PROC_DEF_ID_);

alter table ACT_RU_IDENTITYLINK
    add constraint ACT_FK_ATHRZ_PROCEDEF
    foreign key (PROC_DEF_ID_) 
    references ACT_RE_PROCDEF (ID_);
    
alter table ACT_RU_EXECUTION 
	add CACHED_ENT_STATE_ INTEGER;

update ACT_RU_EXECUTION set CACHED_ENT_STATE_ = 7;
	
alter table ACT_RE_PROCDEF
    add constraint ACT_UNIQ_PROCDEF
    unique (KEY_,VERSION_);
    
--
-- Update engine properties table
--
UPDATE ACT_GE_PROPERTY SET VALUE_ = '5.10' WHERE NAME_ = 'schema.version';
UPDATE ACT_GE_PROPERTY SET VALUE_ = 'create(5.7) upgrade(5.10)' WHERE NAME_ = 'schema.history';

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V4.2-upgrade-to-activiti-5.10';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V4.2-upgrade-to-activiti-5.10', 'Manually executed script upgrade V4.2: Upgraded Activiti tables to 5.10 version',
    0, 5111, -1, 5112, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );