-- Project: Hospital Readmission Risk Prediction: Diabetes
-- File: 02_readmission_metrics.sql
-- Purpose: Create core hospital readmission KPIs to understand overall readmission patterns
-- Author: Ari M.



-- 1. Overall readmission rate
-- To givea baseline understanding of how common 30-day readmissions are in the dataset
SELECT 
    ROUND(AVG(readmitted_30::numeric), 4) AS overall_readmission_rate
FROM diabetic_data;

-- 0.1116  (~11%, so definitely not balanced)


-- 2. Readmission count breakdown
-- Shows class imbalance (important for modeling decisions later)
SELECT 
    readmitted_30,
    COUNT(*) AS total_patients,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM diabetic_data
GROUP BY readmitted_30
ORDER BY readmitted_30;

-- 0: 90409 (88.84%)
-- 1: 11357 (11.16%)
-- A pretty imbalanced dataset


-- 3. Readmission rate by age group
-- Quick check to see if readmission increases with age
-- The trend I expect is older patients have higher readmission, but just sanity checking that it actually shows up here
SELECT 
    age,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY age
ORDER BY age;

-- Kids/young groups are low, then it creeps up
-- Peaks around older age bands but not super linear though


-- 4. Readmission rate by gender
-- Checking if there’s any noticeable difference by gender
-- Usually not a super strong signal but worth confirming anyway
SELECT 
    gender,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
GROUP BY gender;

-- Unknown/Invalid ~0.000
-- Male   ~0.111
-- Female ~0.112
-- Basically no meaningful gap here


-- 5. Readmission rate by race  (excluding missing/unknowns)
-- Looking for any noticeable differences in readmission rates across race groups
-- Just trying to see if anything stands out here or if it's all noise
SELECT 
    race,
    COUNT(*) AS total_patients,
    ROUND(AVG(readmitted_30::numeric), 3) AS readmission_rate
FROM diabetic_data
WHERE race IS NOT NULL AND race <> '?'
GROUP BY race
ORDER BY readmission_rate DESC;


-- Caucasian: ~0.113
-- AfricanAmerican: ~0.112
-- Hispanic: ~0.104
-- Asian: ~0.101
-- Other:  ~0.096

-- Nothing too dramatic here, differences are pretty small overall

