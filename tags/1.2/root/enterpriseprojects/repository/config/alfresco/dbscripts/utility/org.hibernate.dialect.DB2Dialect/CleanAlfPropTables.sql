-- The script intended to clean obsolete properties from alf_prop_xxx tables
-- see MNT-10067
-- 
-- All the useful properties in alf_prop_root are gathered in temp_prop_root_ref.
-- These can be found in alf_audit_app.disabled_paths_id, alf_audit_entry.audit_values_id, alf_prop_unique_ctx.prop1_id
-- Then the obsolete ones are put to temp_prop_root_obs and deleted.
--
-- Afterwards, all the usefull properties in alf_prop_value are gathered in temp_prop_val_ref.
-- These can be found in alf_audit_app.app_name_id, alf_audit_entry.audit_user_id, alf_prop_link.key_prop_id, alf_prop_link.key_prop_id,
-- alf_prop_unique_ctx.value1_prop_id, alf_prop_unique_ctx.value2_prop_id, alf_prop_unique_ctx.value3_prop_id.
-- All of these tables are participating in recording audit. Afterwards the obsolete values in alf_prop_value are deleted.
-- Knowing all the ID's gathered in temp_prop_val_obs.long_value with a combination of the properties type in temp_prop_val_obs.persisted_type,
-- the rest of the values used in audit can be deleted from alf_prop_string_value, alf_prop_serializable_value, alf_prop_double_value.

--BEGIN TXN

-- create temp tables
create table temp_prop_root_ref
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY
);
CREATE INDEX idx_temp_prop_root_ref_id ON temp_prop_root_ref(id);
create table temp_prop_root_obs
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY
);
CREATE INDEX idx_temp_prop_root_obs_id ON temp_prop_root_obs(id);
create table temp_prop_val_ref
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY
);
CREATE INDEX idx_temp_prop_val_ref_id ON temp_prop_val_ref(id);
create table temp_prop_val_obs
(
   id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
   persisted_type SMALLINT NOT NULL,
   long_value BIGINT NOT NULL
);
CREATE INDEX idx_temp_prop_val_obs_id ON temp_prop_val_obs(id);
CREATE INDEX idx_temp_prop_val_obs_per ON temp_prop_val_obs(persisted_type, id, long_value);

create table temp_del_str1
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    PRIMARY KEY (id)
);
create table temp_del_str2
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    PRIMARY KEY (id)
);
create table temp_del_ser1
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    PRIMARY KEY (id)
);
create table temp_del_ser2
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    PRIMARY KEY (id)
);
create table temp_del_double1
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    PRIMARY KEY (id)
);
create table temp_del_double2
(
    id BIGINT NOT NULL GENERATED BY DEFAULT AS IDENTITY,
    PRIMARY KEY (id)
);

-- get all active references to alf_prop_root
--FOREACH alf_audit_app.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_root_ref(id) select disabled_paths_id as id from alf_audit_app where id >= ${LOWERBOUND} and id <= ${UPPERBOUND};
--FOREACH alf_audit_entry.audit_values_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_root_ref(id) select audit_values_id from alf_audit_entry where audit_values_id >= ${LOWERBOUND} and audit_values_id <= ${UPPERBOUND};
--FOREACH alf_prop_unique_ctx.prop1_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_root_ref(id) select prop1_id from alf_prop_unique_ctx where prop1_id is not null and prop1_id >= ${LOWERBOUND} and prop1_id <= ${UPPERBOUND};

-- determine the obsolete entries from alf_prop_root
--FOREACH alf_prop_root.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_root_obs(id) select alf_prop_root.id from alf_prop_root left join temp_prop_root_ref on temp_prop_root_ref.id = alf_prop_root.id where temp_prop_root_ref.id is null and alf_prop_root.id >= ${LOWERBOUND} and alf_prop_root.id <= ${UPPERBOUND};

-- clear alf_prop_root which cascades DELETE to alf_prop_link
--FOREACH temp_prop_root_obs.id system.upgrade.clean_alf_prop_tables.batchsize
delete from alf_prop_root where id in (select id from temp_prop_root_obs where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- get all active references to alf_prop_value
--FOREACH alf_prop_value.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select id from alf_prop_value where id in (select app_name_id from alf_audit_app) and id >= ${LOWERBOUND} and id <= ${UPPERBOUND};
--FOREACH alf_audit_entry.audit_user_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select audit_user_id from alf_audit_entry where audit_user_id >= ${LOWERBOUND} and audit_user_id <= ${UPPERBOUND};
--FOREACH alf_prop_link.key_prop_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select key_prop_id from alf_prop_link where key_prop_id >= ${LOWERBOUND} and key_prop_id <= ${UPPERBOUND};
--FOREACH alf_prop_link.value_prop_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select value_prop_id from alf_prop_link where value_prop_id >= ${LOWERBOUND} and value_prop_id <= ${UPPERBOUND};
--FOREACH alf_prop_unique_ctx.value1_prop_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select value1_prop_id from alf_prop_unique_ctx where value1_prop_id >= ${LOWERBOUND} and value1_prop_id <= ${UPPERBOUND};
--FOREACH alf_prop_unique_ctx.value2_prop_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select value2_prop_id from alf_prop_unique_ctx where value2_prop_id >= ${LOWERBOUND} and value2_prop_id <= ${UPPERBOUND};
--FOREACH alf_prop_unique_ctx.value3_prop_id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_ref(id) select value3_prop_id from alf_prop_unique_ctx where value3_prop_id >= ${LOWERBOUND} and value3_prop_id <= ${UPPERBOUND};

-- determine the obsolete entries from alf_prop_value
--FOREACH alf_prop_value.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_prop_val_obs(id, persisted_type, long_value) select apv.id, apv.persisted_type, apv.long_value from alf_prop_value apv left join temp_prop_val_ref on (apv.id = temp_prop_val_ref.id) where temp_prop_val_ref.id is null and apv.id >= ${LOWERBOUND} and apv.id <= ${UPPERBOUND};

-- clear the obsolete entries
--FOREACH temp_prop_val_obs.id system.upgrade.clean_alf_prop_tables.batchsize
delete from alf_prop_value where id in (select id from temp_prop_val_obs where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- find and clear obsoleted string values
-- find the strings already deleted
--FOREACH temp_prop_val_obs.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_del_str1(id) select distinct pva.long_value from temp_prop_val_obs pva where pva.persisted_type in (3, 5, 6) and pva.id >= ${LOWERBOUND} and pva.id <= ${UPPERBOUND};
--FOREACH temp_del_str1.id system.upgrade.clean_alf_prop_tables.batchsize
delete from alf_prop_string_value where id in (select id from temp_del_str1 where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- or added only to the alf_prop_string_value
-- disabled, as it is an edge case and the query is rather slow, see MNT-10067
-- FOREACH alf_prop_string_value.id system.upgrade.clean_alf_prop_tables.batchsize
-- insert into temp_del_str2(id) select aps.id from alf_prop_string_value aps left join alf_prop_value apv on apv.long_value = aps.id and apv.persisted_type in (3, 5, 6) where apv.id is null and aps.id >= ${LOWERBOUND} and aps.id <= ${UPPERBOUND};
-- FOREACH temp_del_str2.id system.upgrade.clean_alf_prop_tables.batchsize
-- delete from alf_prop_string_value where id in (select id from temp_del_str2 where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- find and clear obsoleted serialized values
-- find the serialized values already deleted
--FOREACH temp_prop_val_obs.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_del_ser1(id) select distinct pva.long_value from temp_prop_val_obs pva where pva.persisted_type = 4 and pva.id >= ${LOWERBOUND} and pva.id <= ${UPPERBOUND};
--FOREACH temp_del_ser1.id system.upgrade.clean_alf_prop_tables.batchsize
delete from alf_prop_serializable_value where id in (select id from temp_del_ser1 where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- disabled, as it is an edge case and the query is rather slow, see MNT-10067
-- FOREACH alf_prop_serializable_value.id system.upgrade.clean_alf_prop_tables.batchsize
-- insert into temp_del_ser2(id) select aps.id from alf_prop_serializable_value aps left join alf_prop_value apv on apv.long_value = aps.id and apv.persisted_type = 4 where apv.id is null and aps.id >= ${LOWERBOUND} and aps.id <= ${UPPERBOUND};
-- FOREACH temp_del_ser2.id system.upgrade.clean_alf_prop_tables.batchsize
-- delete from alf_prop_serializable_value where id in (select id from temp_del_ser2 where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- find and clear obsoleted double values
-- find the double values already deleted
--FOREACH temp_prop_val_obs.id system.upgrade.clean_alf_prop_tables.batchsize
insert into temp_del_double1(id) select distinct pva.long_value from temp_prop_val_obs pva where pva.persisted_type = 2 and pva.id >= ${LOWERBOUND} and pva.id <= ${UPPERBOUND};
--FOREACH temp_del_double1.id system.upgrade.clean_alf_prop_tables.batchsize
delete from alf_prop_double_value where id in (select id from temp_del_double1 where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

-- disabled, as it is an edge case and the query is rather slow, see MNT-10067
-- FOREACH alf_prop_double_value.id system.upgrade.clean_alf_prop_tables.batchsize
-- insert into temp_del_double2(id) select apd.id from alf_prop_double_value apd left join alf_prop_value apv on apv.long_value = apd.id and apv.persisted_type = 2 where apv.id is null and apd.id >= ${LOWERBOUND} and apd.id <= ${UPPERBOUND};
-- FOREACH temp_del_double2.id system.upgrade.clean_alf_prop_tables.batchsize
-- delete from alf_prop_double_value where id in (select id from temp_del_double2 where id >= ${LOWERBOUND} and id <= ${UPPERBOUND});

--END TXN
