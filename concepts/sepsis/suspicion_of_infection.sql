-- Note this query does not do much in the way of finding suspicion of infections before ICU admission, in that case the prescriptions table should be incorporated

-- We explore the idea of splitting medications by different treatment cycles and removing patients with isolated antibiotic events 

-- As mentioned in the sepsis-3 paper, isolated cases of antibiotics would not satisfy the requirement for a suspicion of infection. We need another dose of antibiotics within 96 hours of the first one

with abx_partition as
(
select *,
 sum( new_antibiotics_cycle )
      over ( partition by stay_id, antibiotic_name order by stay_id, starttime )
    as abx_num
 from
  (select subject_id, hadm_id, stay_id, starttime, endtime
   , label as antibiotic_name
   -- Check if the same antibiotics was taken in the last 4 days
   , case when starttime <= datetime_add(lag(endtime) over (partition by stay_id, label order by stay_id, starttime), interval 96 hour) then 0 else 1 end as new_antibiotics_cycle
   , datetime_diff(lead(starttime) over (partition by stay_id order by stay_id, starttime), endtime, second)/3600 as next_antibio_time
   --, datetime_diff(lead(starttime) over (partition by stay_id order by stay_id, starttime), endtime, hour) as next_antibio_time
   , case when lead(starttime) over (partition by stay_id order by stay_id, starttime)  <= datetime_add(endtime, interval 96 hour) then 0 else 1 end as isolated_case
   from `physionet-data.mimic_icu.inputevents` input
inner join `physionet-data.mimic_icu.d_items` d on input.itemid = d.itemid
where upper(d.category) like '%ANTIBIOTICS%'
) A
order by subject_id, hadm_id, stay_id, starttime
)

-- group the antibiotic information together to form courses of antibiotics and also to check whether they are isolated cases

-- note the last drug dose taken by the patient will be classed as an isolated case. However, if this is of the same type as antibiotics given to patient within last 4 days, then it will be aggreagated with the other doses in the next query.

, abx_partition_grouped as
(
select subject_id, hadm_id, stay_id, min(starttime) as starttime, max(endtime) as endtime
    , count(*) as doses, antibiotic_name, min(isolated_case) as isolated_case
from abx_partition
group by subject_id, hadm_id, stay_id, antibiotic_name, abx_num
order by subject_id, hadm_id, stay_id, starttime
)

, ab_tbl as
(
  select
        ie.subject_id, ie.hadm_id, ie.stay_id
      , ie.intime, ie.outtime
      , case when ab.isolated_case = 0 then ab.antibiotic_name else null end as antibiotic_name
      , case when ab.isolated_case = 0 then ab.starttime else null end as antibiotic_time
      --, ab.isolated_case
      --, abx.endtime
  from `physionet-data.mimic_icu.icustays` ie
  left join abx_partition_grouped ab
      on ie.hadm_id = ab.hadm_id and ie.stay_id = ab.stay_id
)

-- Find the microbiology events
, me as
(
  select subject_id, hadm_id
    , chartdate, charttime
    , spec_type_desc
    , max(case when org_name is not null and org_name != '' then 1 else 0 end) as PositiveCulture
  from  `physionet-data.mimic_hosp.microbiologyevents`  
  group by subject_id, hadm_id, chartdate, charttime, spec_type_desc
)

, ab_fnl as
(
  select
      ab_tbl.stay_id, ab_tbl.intime, ab_tbl.outtime
    , ab_tbl.antibiotic_name
    , ab_tbl.antibiotic_time
    , coalesce(me.charttime,me.chartdate) as culture_charttime
    , me.positiveculture as positiveculture
    , me.spec_type_desc as specimen
    , case
      when coalesce(antibiotic_time,coalesce(me.charttime,me.chartdate)) is null
        then 0
      else 1 end as suspected_infection
    , least(antibiotic_time, coalesce(me.charttime,me.chartdate)) as t_suspicion
  from ab_tbl
  left join me 
    on ab_tbl.hadm_id = me.hadm_id
    and ab_tbl.antibiotic_time is not null
    and
    (
      -- if charttime is available, use it
      (
          ab_tbl.antibiotic_time >= datetime_sub(me.charttime, interval 24 hour)
      and ab_tbl.antibiotic_time <= datetime_add(me.charttime, interval 72 hour)

      )
      OR
      (
      -- if charttime is not available, use chartdate
          me.charttime is null
      and ab_tbl.antibiotic_time >= datetime_sub(me.chartdate, interval 24 hour)
      and ab_tbl.antibiotic_time < datetime_add(me.chartdate, interval 96 hour) --  Note this is 96 hours to include cases of when antibiotics are given 3 days after chart date of culture
      )
    )
)

-- select only the unique times for suspicion of infection
, unique_times as 
(
select stay_id, t_suspicion, count(*) as repeats from ab_fnl
group by stay_id, t_suspicion
order by stay_id, t_suspicion
)

