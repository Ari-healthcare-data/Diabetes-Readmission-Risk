-- Project: Hospital Readmission Prediction
-- File: 03_utilization_analysis.sql
-- Purpose: Analyze how healthcare utilization patterns influence 30-day readmission risk
-- Author: Ari M.



-- 1. Readmission rate by prior inpatient visits
-- Check if people who were already hospitalized more often tend to come back within 30 days
SELECT 
    number_inpatient,
    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY number_inpatient
ORDER BY number_inpatient;

-- "number_inpatient"	"total_patients"	"readmitted_count"	"readmission_rate"
-- 0	67630	5706	0.084
-- 1	19521	2523	0.129
-- 2	7566	1319	0.174
-- 3	3411	692	0.203
-- ... continues upward, a bit noisy at the tail
-- 17	1	1	1.000
-- 18	1	0	0.000
-- 19	2	1	0.500
-- 21	1	1	1.000

-- This one is probably the clearest signal in the whole dataset.
-- More prior inpatient visits = higher readmission rate, pretty steady climb overall
-- Feels like a proxy for "sicker / more complicated patients" rather than anything random



-- 2. Readmission rate by inpatient visit buckets
-- Bucketing inpatient visits to make it easier to explain
-- I wanted to simplify the above because the raw numbers get messy fast
SELECT 
    CASE 
        WHEN number_inpatient = 0 THEN '0 visits'
        WHEN number_inpatient BETWEEN 1 AND 2 THEN '1-2 visits'
        WHEN number_inpatient BETWEEN 3 AND 5 THEN '3-5 visits'
        ELSE '6+ visits'
    END AS inpatient_bucket,
    
    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate

FROM diabetic_data
GROUP BY inpatient_bucket
ORDER BY readmission_rate;

-- 0 visits     0.084
-- 1-2 visits   0.142
-- 3-5 visits   0.228
-- 6+ visits    0.398

-- The "6+ visits" group is small but jumps a lot in risk
-- Not sure how stable that is statistically, but directionally it makes sense



-- 3. Readmission rate by emergency visits
-- Question: Do ER-heavy patients bounce back more often?
-- I want to see whether emergency care usage is associated with readmission
SELECT 
    number_emergency,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY number_emergency
ORDER BY number_emergency;

-- 0 visits ~0.105
-- 1 visit  ~0.144
-- 2 visits ~0.183
-- after that it gets pretty jumpy

-- takeaway:
-- There is an upward trend but it’s not as clean as inpatient visits
-- I think small sample sizes at higher counts are messing with stability here



-- 4. Readmission rate by outpatient visits
-- Assess whether outpatient engagement reduces or increases readmission risk
SELECT 
    number_outpatient,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY number_outpatient
ORDER BY number_outpatient;

-- mostly hovering around ~0.10–0.15 with no obvious pattern
-- I honestly expected this to show something stronger (like maybe protective effect), but it’s messy
-- Outpatient visits alone don’t seem like a strong signal here
-- Could still matter in combination with other features though



-- 5. Readmission rate by number of medications
-- Trying to see if treatment complexity correlates with readmission
SELECT 
    num_medications,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY num_medications
ORDER BY num_medications;

-- low meds ~0.04–0.08
-- mid range slowly creeps toward ~0.10–0.13
-- some noise at extremes

-- Weak-to-moderate upward drift, but not super strong
-- Feels less predictive than inpatient history
-- Some of the extreme medication counts have tiny sample sizes
-- I don’t fully trust those edge values (like 60+ meds)



-- 6. Readmission rate by medication change
-- Check whether patients who had changes in diabetic medication tend to be more likely to be readmitted
-- This might be a rough proxy for treatment adjustment / instability in management
SELECT 
    change,  -- in this dataset: 'Ch' = changed, 'No' = no change
    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY change
ORDER BY change;

-- Results (from run):
-- No   0.106
-- Ch   0.118

-- Patients with medication changes show a slightly higher readmission rate.
-- At first glance this could suggest that medication changes are linked to higher risk of readmission, but realistically this is probably not causal.
-- It adds a "treatment adjustment" dimension on top of the utilization variables, and it may become more meaningful when combined with other features in a model.


-- 7. Readmission rate by length of hospital stay
-- Do longer stays might reflect severity or maybe higher readmission risk?
-- I want to determine whether longer hospital stays indicate higher readmission risk
SELECT 
    time_in_hospital,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;

-- Gradual increase from ~0.08 (1 day) up to ~0.14-ish (longer stays)
-- There’s a mild upward trend
-- Not dramatic, but it does suggest severity/complication link



-- 8. Combined utilization comparison
-- Wanted a quick side-by-side summary instead of looking at each column separately
-- Compare multiple utilization metrics across readmission groups
SELECT
    readmitted_30,
    ROUND(AVG(number_inpatient), 2) AS avg_inpatient,
    ROUND(AVG(number_emergency), 2) AS avg_emergency,
    ROUND(AVG(number_outpatient), 2) AS avg_outpatient,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(time_in_hospital), 2) AS avg_length_of_stay,
    ROUND(AVG(CASE WHEN change = 'Ch' THEN 1 ELSE 0 END)::numeric, 3) AS avg_med_change_rate
FROM diabetic_data
GROUP BY readmitted_30;

-- 0	0.56	0.18	0.36	15.91	4.35	0.459
-- 1	1.22	0.36	0.44	16.90	4.77	0.489

-- non-readmitted: lower averages across everything
-- readmitted: consistently higher across all utilization metrics


-- Final thoughts
-- Inpatient history stands out the most by far
-- Medication changes are happening more often in patients who are already more complex / unstable, so the variable is probably acting as a proxy for severity rather than a direct driver
-- Everything else seems to be weaker / noisier

-- Overall feels like utilization history is useful, but not equally useful across all types
-- If I were to move forward, I’d expect inpatient visits and maybe length of stay to carry the most weight in a predictive model
-- The rest (especially outpatient and emergency visits) might only show value in combination with other features rather than on their own
