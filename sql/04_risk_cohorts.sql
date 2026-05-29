-- Project: Hospital Readmission Risk Prediction: Diabetes
-- File: 04_risk_cohorts.sql
-- Purpose: Identify high-risk patient cohorts based on healthcare utilization patterns
-- Author: Ari M.


-- 1. High inpatient utilization cohort
-- Identify patients with high prior inpatient visits and evaluate their readmission risk
-- See how cleanly inpatient history alone separates risk groups (this feature looked strongest in the previous file so I’m leaning into it)
SELECT
    CASE 
        WHEN number_inpatient = 0 THEN 'Low (0 visits)'
        WHEN number_inpatient BETWEEN 1 AND 2 THEN 'Moderate (1-2 visits)'
        WHEN number_inpatient BETWEEN 3 AND 5 THEN 'High (3-5 visits)'
        ELSE 'Very High (6+ visits)'
    END AS inpatient_risk_group,

    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate

FROM diabetic_data
GROUP BY inpatient_risk_group
ORDER BY readmission_rate;

-- Low (0 visits)              67630   5706   0.084
-- Moderate (1-2 visits)       27087   3842   0.142
-- High (3-5 visits)           5845    1330   0.228
-- Very High (6+ visits)       1204    479    0.398

-- This one is honestly pretty striking.
-- It’s not subtle at all — more inpatient history = higher readmission risk.
-- Feels less like a “feature” and more like a proxy for overall illness severity / complexity
-- I don’t think this is just noise.



-- 2. Combined utilization risk cohort
-- Identify high-risk patients using multiple utilization indicators
-- Try mixing inpatient history with medication burden, not 100% sure this will add much signal, but worth testing
SELECT
    CASE
        WHEN number_inpatient >= 3 AND num_medications >= 20 THEN 'High Risk (Inpatient + Medications)'
        WHEN number_inpatient >= 3 THEN 'Inpatient Driven Risk'
        WHEN num_medications >= 20 THEN 'Medication Driven Risk'
        ELSE 'Lower Risk'
    END AS risk_group,

    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate

FROM diabetic_data
GROUP BY risk_group
ORDER BY readmission_rate;

-- Lower Risk                         69606   6642   0.095
-- Medication Driven Risk             25111   2906   0.116
-- High Risk (Inpatient + Meds)       2460    629    0.256
-- Inpatient Driven Risk              4589    1180   0.257

-- Kind of interesting (or maybe expected?) result here
-- Combining meds + inpatient doesn’t really beat inpatient alone
-- Inpatient history still seems to be doing most of the heavy lifting
-- Meds alone are a weak signal, maybe just picking up “sicker patients” indirectly



-- 3. Inpatient + Length of Stay risk cohort
-- Identify whether combining utilization with encounter severity improves risk segmentation
-- Trying a slightly different angle: severity of stay + prior utilization, not sure if this is actually better than #1, but I wanted to check
SELECT
    CASE
        WHEN number_inpatient >= 3 AND time_in_hospital >= 7 THEN 'High Risk (Inpatient + Long Stay)'
        WHEN number_inpatient >= 3 THEN 'Inpatient Driven Risk'
        WHEN time_in_hospital >= 7 THEN 'Long Stay Risk'
        ELSE 'Lower Risk'
    END AS risk_group,

    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate

FROM diabetic_data
GROUP BY risk_group
ORDER BY readmission_rate;

-- Lower Risk                         75459   7203   0.095
-- Long Stay Risk                    19258   2345   0.122
-- High Risk (Inpatient + Long Stay)  1891    452    0.239
-- Inpatient Driven Risk              5158    1357   0.263

-- Long hospital stays do show higher readmission rates, but it’s not super dramatic
-- Inpatient history still dominates everything else here
-- Even when combining long stays + inpatient visits, the lift isn’t huge
-- So I’m starting to think inpatient count is basically the “core signal” in this dataset


-- Overall Impression:
-- These cohort splits are helpful for storytelling / interpretation
-- But they don’t really beat the simpler inpatient-based segmentation
-- If anything, they reinforce it rather than improve on it



