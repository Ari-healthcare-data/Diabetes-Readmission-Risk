-- Project: Hospital Readmission Prediction
-- File: 07_patient_risk_summary.sql
-- Purpose: Roll encounter-level risk scores up to the patient level so it's easier to identify patients with repeated high-risk utilization patterns
-- Author: Ari M.



-- 1. Encounter-level Risk Scoring Table
-- Build encounter-level risk buckets first
DROP TABLE IF EXISTS patient_risk_encounter_scores;

CREATE TABLE patient_risk_encounter_scores AS
SELECT
    encounter_id,
    patient_nbr,
    utilization_score,
    CASE
        WHEN utilization_score >= 10 THEN 'High'
        WHEN utilization_score BETWEEN 4 AND 9 THEN 'Medium'
        ELSE 'Low'
    END AS risk_level
FROM patient_features;



-- Quick spot check
SELECT *
FROM patient_risk_encounter_scores
LIMIT 10;



-- 2. Patient Dimention Table
-- Keeping a few summary stats per patient
DROP TABLE IF EXISTS dim_patient;

CREATE TABLE dim_patient AS
SELECT
    patient_nbr,
    COUNT(*) AS total_encounters,
    MAX(utilization_score) AS max_utilization_score,
    AVG(utilization_score) AS avg_utilization_score
FROM patient_features
GROUP BY patient_nbr;

-- sanity check
SELECT COUNT(*) 
FROM dim_patient;

SELECT * 
FROM dim_patient
LIMIT 10;



-- 3. Main patient-level summary table
DROP TABLE IF EXISTS patient_risk_summary;

CREATE TABLE patient_risk_summary AS
SELECT
    e.patient_nbr,

    COUNT(*) AS total_encounters,

    MAX(e.utilization_score) AS max_utilization_score,
    AVG(e.utilization_score) AS avg_utilization_score,

    -- encounter mix
    SUM(CASE WHEN e.risk_level = 'High' THEN 1 ELSE 0 END) AS high_risk_encounters,
    SUM(CASE WHEN e.risk_level = 'Medium' THEN 1 ELSE 0 END) AS medium_risk_encounters,
    SUM(CASE WHEN e.risk_level = 'Low' THEN 1 ELSE 0 END) AS low_risk_encounters,

    -- share of encounters classified as high risk
    ROUND(
        SUM(CASE WHEN e.risk_level = 'High' THEN 1 ELSE 0 END)::NUMERIC
        / COUNT(*),
        4
    ) AS high_risk_ratio,

    -- simple patient grouping
    CASE
        WHEN SUM(CASE WHEN e.risk_level = 'High' THEN 1 ELSE 0 END) >= 2 THEN 'Chronic High Risk'
        WHEN SUM(CASE WHEN e.risk_level = 'High' THEN 1 ELSE 0 END) = 1 THEN 'Intermittent High Risk'
        ELSE 'Low Risk Patient'
    END AS patient_risk_category,

    AVG(f.num_medications) AS avg_num_medications,
    AVG(f.time_in_hospital) AS avg_length_of_stay,
    AVG(f.number_inpatient) AS avg_inpatient_visits,

    -- average readmission rate across encounters
    ROUND(AVG(f.readmitted_30::numeric), 4) AS readmission_rate_30d

FROM patient_risk_encounter_scores e
JOIN patient_features f
    ON e.encounter_id = f.encounter_id

GROUP BY e.patient_nbr;



-- 4. Final Validation Dashboard Table Check
-- Looking at highest-utilization patients first
SELECT *
FROM patient_risk_summary
ORDER BY max_utilization_score DESC
LIMIT 10;



-- Total patient count
SELECT COUNT(*) AS total_patients
FROM patient_risk_summary;


-- Distribution of patient risk groups
SELECT patient_risk_category, COUNT(*) AS patients
FROM patient_risk_summary
GROUP BY patient_risk_category
ORDER BY patients DESC;


-- Top risk patients
SELECT *
FROM patient_risk_summary
ORDER BY max_utilization_score DESC
LIMIT 10;




