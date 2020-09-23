-- Around each suspicion of infection, check the changes of the current SOFA score from the beginning of the window
, sofa_scores as
(
select 
    sus.stay_id, hr, starttime, endtime, t_suspicion, sofa_24hours
    , first_value(sofa_24hours) over (partition by sofa.stay_id, t_suspicion order by sofa.stay_id, t_suspicion, starttime) as initial_sofa
    , sofa_24hours - first_value(sofa_24hours) over (partition by sofa.stay_id, t_suspicion order by sofa.stay_id, t_suspicion, starttime) as sofa_difference
from `physionet-data.mimic_derived.suspicion_of_infection` sus
left join `physionet-data.mimic_derived.sofa` sofa
    on sus.stay_id = sofa.stay_id
-- the following is the largest interval suggested by the sepsis-3 paper, though their sensitivity analysis checked +-3 hours upwards
where starttime <= datetime_add(t_suspicion, interval 24 hour)
    and starttime >= datetime_sub(t_suspicion, interval 48 hour) 
order by sofa.stay_id, t_suspicion, starttime
)

-- find where the SOFA score has increased by 2 within the time sensitivity being investigated
-- Note the sepsis-3 papers mentions that the baseline of a patient should be zero so an alternative is just to test if the total SOFA score exceeds 2. However that approach would have lower specificity and may be less clinically interesting
, sofa_times as 
(
select stay_id, t_suspicion, min(starttime) as t_sofa
from sofa_scores
where sofa_difference>=2
group by stay_id, t_suspicion
)

-- Find the first time when the sepsis-3 requirements are satisfied
, first_event as
(
select stay_id, min(t_suspicion) as t_suspicion, min(t_sofa) as t_sofa from sofa_times
    group by stay_id
)

select subject_id, hadm_id, ie.stay_id, intime, outtime
    , t_suspicion, t_sofa 
    -- some papers may take the minimum to define sepsis time
    , least(t_suspicion, t_sofa) as t_sepsis_min
from `physionet-data.mimic_icu.icustays` ie
left join first_event fe on ie.stay_id = fe.stay_id
order by subject_id, intime
