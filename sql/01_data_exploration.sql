-- Project: Hospital Readmission Prediction
-- File: 01_data_exploration.sql
-- Purpose: To understand structure, missing values, class balance, and basic patterns in patient utilization.
-- Author: Ari M.



-- 1. Total number of encouners
SELECT COUNT(*) AS total_rows
FROM diabetic_data;

-- 101766 rows


-- 2. Unique patients vs encounters
-- Since one patient can appear multiple times
SELECT 
    COUNT(DISTINCT patient_nbr) AS unique_patients,
    COUNT(DISTINCT encounter_id) AS unique_encounters
FROM diabetic_data;

-- 71518 unique patients
-- 101766 unique encounters



-- 3. Readmission distribution
-- Readmission target balance
SELECT 
    readmitted_30,
    COUNT(*) AS count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM diabetic_data
GROUP BY readmitted_30
ORDER BY readmitted_30;

-- Definitely imbalanced
-- Only around 11% positive cases



-- 4. Missing values check for key columns
SELECT
    COUNT(*) FILTER (WHERE race IS NULL OR race = '?') AS missing_race,
    COUNT(*) FILTER (WHERE gender IS NULL OR gender = '?') AS missing_gender,
    COUNT(*) FILTER (WHERE payer_code IS NULL OR payer_code = '?') AS missing_payer_code,
    COUNT(*) FILTER (WHERE medical_specialty IS NULL OR medical_specialty = '?') AS missing_specialty
FROM diabetic_data;

-- payer_code &  specialty have a LOT missing (40256 & 49949 missing)
-- Might need to bucket or drop later depending on model performance


-- 5. Age distribution
SELECT 
    age,
    COUNT(*) AS count
FROM diabetic_data
GROUP BY age
ORDER BY age;

-- Most patients are older, especially 60-80 range


-- 6. Length of stay distribution
SELECT 
    time_in_hospital,
    COUNT(*) AS count
FROM diabetic_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;

-- Most stays are pretty short
-- 1-4 days dominates


-- 7. Prior inpatient visits 
SELECT 
    number_inpatient,
    COUNT(*) AS count
FROM diabetic_data
GROUP BY number_inpatient
ORDER BY number_inpatient;

-- Most patients have 0 previous inpatient visits, but a smaller group has very high counts


-- 8. Readmission rate by prior inpatient visits
-- Want to see if prior inpatient history has any relationship with readmission
SELECT 
    number_inpatient,
    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_count,
    ROUND(AVG(readmitted_30)::numeric, 3) AS readmission_rate
FROM diabetic_data
GROUP BY number_inpatient
ORDER BY number_inpatient;

-- Pretty strong pattern here
-- Readmission rate climbs a lot as inpatient visits increase

-- Examples:
-- 0 prior visits  -> ~8%
-- 5 prior visits  -> ~31%

-- Seems like utilization history may end up being one of the strongest predictors


-- 9. Average utilization metrics by readmission status
-- Comparing average utilization metrics between readmitted vs not readmitted patients
SELECT
    readmitted_30,
    ROUND(AVG(number_inpatient), 2) AS avg_inpatient_visits,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(time_in_hospital), 2) AS avg_length_of_stay
FROM diabetic_data
GROUP BY readmitted_30;

-- Readmitted patients are slightly higher across everything, but inpatient history stands out the most

-- avg inpatient visits:
-- 0.56 -> 1.22

-- Medication count and LOS increase too, just not nearly as dramatic