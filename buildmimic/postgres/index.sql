-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-IV indexes for Postgres.
--
-- Based on the MySQL index script.
--
-- ----------------------------------------------------------------


-- -----------
-- admissions
-- -----------

drop index if exists admissions_idx01;
create index admissions_idx01 on admissions (subject_id,hadm_id);

drop index if exists admissions_idx02;
create index admissions_idx02 on admissions (admittime, dischtime, deathtime);

drop index if exists admissions_idx03;
create index admissions_idx03 on admissions (admission_type);

drop index if exists admissions_idx04;
create unique index admissions_idx04 on admissions (hadm_id);

-- -------------
-- chartevents
-- -------------
drop index if exists chartevents_idx01;
create index chartevents_idx01 on chartevents (subject_id, hadm_id, stay_id);

drop index if exists chartevents_idx02;
create index chartevents_idx02 on chartevents (itemid);

drop index if exists chartevents_idx03;
create index chartevents_idx03 on chartevents (charttime, storetime);

-- Perhaps not useful to index on just value? Index just for popular subset?
-- CREATE INDEX CHARTEVENTS_idx05 ON CHARTEVENTS on (VALUE);

-- -----------
-- d_hcpcs
-- -----------

drop index if exists charteventd_hcpcs_idx01s_idx01;
create unique index d_hcpcs_idx01 on d_hcpcs (code);

-- -----------
-- d_icd_diagnoses
-- -----------

drop index if exists d_icd_diagnoses_icd_code_icd_version;
create unique index d_icd_diagnoses_icd_code_icd_version on d_icd_diagnoses (icd_code, icd_version);

-- -----------
-- d_icd_procedures
-- -----------

drop index if exists d_icd_procedures_idx01;
create unique index d_icd_procedures_idx01 on d_icd_procedures (icd_code);

-- ---------
-- d_items
-- ---------

drop index if exists d_items_idx01;
create unique index d_items_idx01 on d_items (itemid);

drop index if exists d_items_idx02;
create index d_items_idx02 on d_items (left(label, 200));

drop index if exists d_items_idx03;
create index d_items_idx03 on d_items (category);

drop index if exists d_items_idx04;
create index d_items_idx04 on d_items (abbreviation);

drop index if exists d_items_idx05;
create index d_items_idx05 on d_items (param_type);



-- -------------
-- d_labitems
-- -------------

drop index if exists d_labitems_idx01;
create unique index d_labitems_idx01 on d_labitems (itemid);

drop index if exists d_labitems_idx01;
create index d_labitems_idx02 on d_labitems (label, fluid, category);  

drop index if exists d_labitems_idx01;
create index d_labitems_idx03 on d_labitems (loinc_code);

-- -----------------
-- datetimeevents
-- -----------------

drop index if exists datetimeevents_idx01;
create index datetimeevents_idx01 on datetimeevents (subject_id, hadm_id, stay_id);

drop index if exists datetimeevents_idx02;
create index datetimeevents_idx02 on datetimeevents (itemid);

drop index if exists datetimeevents_idx03;
create index datetimeevents_idx03 on datetimeevents (charttime);

drop index if exists datetimeevents_idx04;
create index datetimeevents_idx04 on datetimeevents (value);

-- ----------------
-- diagnoses_icd
-- ----------------

drop index if exists diagnoses_icd_idx01;
create index diagnoses_icd_idx01 on diagnoses_icd (subject_id, hadm_id);

drop index if exists diagnoses_icd_idx02;
create index diagnoses_icd_idx02 on diagnoses_icd (icd_code, icd_version, seq_num);

-- ------------
-- drgcodes
-- ------------

drop index if exists drgcodes_idx01;
create index drgcodes_idx01 on drgcodes (subject_id, hadm_id);

drop index if exists drgcodes_idx02;
create index drgcodes_idx02 on drgcodes (drg_code, drg_type);

drop index if exists drgcodes_idx03;
create index drgcodes_idx03 on drgcodes (left(description, 255), drg_severity);

-- ----------------
-- emar
-- ----------------

drop index if exists emar_idx01;
create index emar_idx01 on emar (emar_id);

drop index if exists emar_idx02;
create index emar_idx02 on emar (subject_id, hadm_id, emar_seq);

drop index if exists emar_idx03;
create index emar_idx03 on emar (poe_id);

drop index if exists emar_idx04;
create index emar_idx04 on emar (pharmacy_id);

drop index if exists emar_idx05;
create index emar_idx05 on emar (charttime, scheduletime, storetime);

drop index if exists emar_idx06;
create index emar_idx06 on emar (medication);

-- ----------------
-- emar_detail
-- ----------------

drop index if exists emar_detail_idx01;
create index emar_detail_idx01 on emar_detail (subject_id, emar_seq);

drop index if exists emar_detail_idx02;
create index emar_detail_idx02 on emar_detail (emar_id);

drop index if exists emar_detail_idx03;
create index emar_detail_idx03 on emar_detail (pharmacy_id);

drop index if exists emar_detail_idx04;
create index emar_detail_idx04 on emar_detail (left(product_description, 200));

drop index if exists emar_detail_idx05;
create index emar_detail_idx05 on emar_detail (product_code);

-- ----------------
-- hcpsevents
-- ----------------

drop index if exists hcpcsevents_idx01;
create index hcpcsevents_idx01 on hcpcsevents (subject_id, hadm_id, seq_num);

drop index if exists hcpcsevents_idx02;
create index hcpcsevents_idx02 on hcpcsevents (hcpcs_cd);
  
-- --------------
-- icustays
-- --------------

drop index if exists icustays_idx01;
create index icustays_idx01 on icustays (subject_id, hadm_id, stay_id);

drop index if exists icustays_idx02;
create index icustays_idx02 on icustays (first_careunit, last_careunit);

drop index if exists icustays_idx03;
create index icustays_idx03 on icustays (intime, outtime);

-- --------------
-- inputevents
-- --------------

drop index if exists inputevents_idx01;
create index inputevents_idx01 on inputevents (subject_id, hadm_id, stay_id);

drop index if exists inputevents_idx02;
create index inputevents_idx02 on inputevents (stay_id);

drop index if exists inputevents_idx03;
create index inputevents_idx03 on inputevents (starttime, endtime);

drop index if exists inputevents_idx04;
create index inputevents_idx04 on inputevents (itemid);

drop index if exists inputevents_idx05;
create index inputevents_idx05 on inputevents (rate);

drop index if exists inputevents_idx06;
create index inputevents_idx06 on inputevents (amount);

-- ------------
-- labevents
-- ------------

drop index if exists labevents_idx01;
create index labevents_idx01 on labevents (subject_id, hadm_id);

drop index if exists labevents_idx02;
create index labevents_idx02 on labevents (itemid);

drop index if exists labevents_idx03;
create index labevents_idx03 on labevents (charttime);

drop index if exists labevents_idx04;
create index labevents_idx04 on labevents (valuenum);

drop index if exists labevents_idx05;
create index labevents_idx05 on labevents (left(value, 200));

drop index if exists labevents_idx06;
create unique index labevents_idx06 on labevents (labevent_id, itemid);
-- Note: itemid on (by which labevents in partitioned) must be part of the primary key.

-- --------------------
-- microbiologyevents
-- --------------------

drop index if exists microbiologyevents_idx01;
create index microbiologyevents_idx01 on microbiologyevents (subject_id, hadm_id);

drop index if exists microbiologyevents_idx02;
create index microbiologyevents_idx02 on microbiologyevents (chartdate, charttime);

drop index if exists microbiologyevents_idx03;
create index microbiologyevents_idx03 on microbiologyevents (spec_itemid, org_itemid, ab_itemid);

-- --------------
-- outputevents
-- --------------

drop index if exists outputevents_idx01;
create index outputevents_idx01 on outputevents (subject_id, hadm_id);

drop index if exists outputevents_idx02;
create index outputevents_idx02 on outputevents (stay_id);

drop index if exists outputevents_idx03;
create index outputevents_idx03 on outputevents (charttime, storetime);

drop index if exists outputevents_idx04;
create index outputevents_idx04 on outputevents (itemid);

drop index if exists outputevents_idx05;
create index outputevents_idx05 on outputevents (value);

-- -----------
-- patients
-- -----------

-- note that subject_id is already indexed as it is unique

drop index if exists patients_idx01;
create unique index patients_idx01 on patients (subject_id);

drop index if exists patients_idx02;
create index patients_idx02 on patients (dod);

drop index if exists patients_idx03;
create index patients_idx03 on patients (anchor_age);

drop index if exists patients_idx04;
create index patients_idx04 on patients (anchor_year);

-- ----------------
-- pharmacy
-- ----------------

drop index if exists pharmacy_idx01;
create index pharmacy_idx01 on pharmacy (subject_id, hadm_id);

drop index if exists pharmacy_idx02;
create index pharmacy_idx02 on pharmacy (pharmacy_id);

drop index if exists pharmacy_idx03;
create index pharmacy_idx03 on pharmacy (starttime, stoptime);

drop index if exists pharmacy_idx04;
create index pharmacy_idx04 on pharmacy (medication);

-- ----------------
-- poe
-- ----------------

drop index if exists poe_idx01;
create unique index poe_idx01 on poe (poe_id, poe_seq);

drop index if exists poe_idx02;
create index poe_idx02 on poe (subject_id, hadm_id);

drop index if exists poe_idx03;
create index poe_idx03 on poe (order_type);

-- ----------------
-- poe-detail
-- ----------------

drop index if exists poe_detail_idx01;
create index poe_detail_idx01 on poe_detail (poe_id, poe_seq);

drop index if exists poe_detail_idx02;
create index poe_detail_idx02 on poe_detail (subject_id);

drop index if exists poe_detail_idx03;
create index poe_detail_idx03 on poe_detail (field_name);

-- ----------------
-- prescriptions
-- ----------------

drop index if exists prescriptions_idx01;
create index prescriptions_idx01 on prescriptions (subject_id, hadm_id);

drop index if exists prescriptions_idx02;
create index prescriptions_idx02 on prescriptions (pharmacy_id);

drop index if exists prescriptions_idx03;
create index prescriptions_idx03 on prescriptions (drug_type);

drop index if exists prescriptions_idx04;
create index prescriptions_idx04 on prescriptions (drug);

drop index if exists prescriptions_idx05;
create index prescriptions_idx05 on prescriptions (starttime, stoptime);

-- -----------------
-- procedureevents
-- -----------------

drop index if exists procedureevents_mv_idx01;
create index procedureevents_mv_idx01 on procedureevents (subject_id, hadm_id);

drop index if exists procedureevents_mv_idx02;
create index procedureevents_mv_idx02 on procedureevents (stay_id);

drop index if exists procedureevents_mv_idx03;
create index procedureevents_mv_idx03 on procedureevents (itemid);

drop index if exists procedureevents_mv_idx04;
create index procedureevents_mv_idx04 on procedureevents (starttime, endtime);

drop index if exists procedureevents_mv_idx05;
create index procedureevents_mv_idx05 on procedureevents (ordercategoryname);
      
-- -----------------
-- procedures_icd
-- -----------------

drop index if exists procedures_icd_idx01;
create index procedures_icd_idx01 on procedures_icd (subject_id, hadm_id, seq_num);

drop index if exists procedures_icd_idx02;
create index procedures_icd_idx02 on procedures_icd (icd_code, icd_version);

-- -----------
-- services
-- -----------

drop index if exists services_idx01;
create index services_idx01 on services (subject_id, hadm_id);

drop index if exists services_idx02;
create index services_idx02 on services (transfertime);

drop index if exists services_idx03;
create index services_idx03 on services (curr_service, prev_service);

-- -----------
-- transfers
-- -----------

drop index if exists transfers_idx01;
create index transfers_idx01 on transfers (subject_id, hadm_id);

drop index if exists transfers_idx02;
create index transfers_idx02 on transfers (eventtype);

drop index if exists transfers_idx03;
create index transfers_idx03 on transfers (careunit);

drop index if exists transfers_idx04;
create index transfers_idx04 on transfers (intime, outtime);

drop index if exists transfers_idx05;
create index transfers_idx05 on transfers (transfer_id);
