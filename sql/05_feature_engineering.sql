-- Project: Hospital Readmission Risk Prediction: Diabetes
-- File: 05_feature_engineering.sql
-- Purpose: Build a feature table for later modeling work
-- Author: Ari M.


-- Dropping and rebuilding the feature table each run
-- Probably not the most elegant approach, but it keeps things clean while iterating.=
DROP TABLE IF EXISTS patient_features;


-- 1. Create feature dataset
-- Build a structured dataset that can be used directly for modeling later
-- Goal here is just to get the main variables I think might matter into one table
-- Keeping it fairly simple for now rather than trying a bunch of complicated transformations

CREATE TABLE patient_features AS
WITH base AS (
    SELECT
        encounter_id,
        patient_nbr,
        readmitted_30,

        number_inpatient,
        number_outpatient,
        number_emergency,
        num_medications,
        time_in_hospital,

        age,
        gender,
        race,

		-- Simple utilization score. -- From the earlier EDA, inpatient visits looked like the strongest signal, so I decided to weight those higher than outpatient visits
		-- This is mostly a heuristic and could definitely be revisited later	
        (number_inpatient * 3 +
         number_emergency * 2 +
         number_outpatient * 1) AS utilization_score

    FROM diabetic_data
)

SELECT
    *,

    -- Risk indicator flags
    -- These thresholds came mostly from patterns I saw in the cohort analysis, not from any formal optimization process
    CASE 
        WHEN number_inpatient >= 3 THEN 1 
        ELSE 0 
    END AS high_inpatient_flag,

	-- Emergency visits were less common overall, so even a couple visits felt worth flagging
    CASE 
        WHEN number_emergency >= 2 THEN 1 
        ELSE 0 
    END AS high_emergency_flag,

    CASE 
        WHEN num_medications >= 20 THEN 1 
        ELSE 0 
    END AS high_medication_flag,

    CASE 
        WHEN time_in_hospital >= 7 THEN 1 
        ELSE 0 
    END AS long_stay_flag,


	-- Mostly included for interpretability
    -- Not sure I'd actually use this exact categorization in a final model
	CASE
        WHEN utilization_score >= 10 THEN 'High Risk'
        WHEN utilization_score BETWEEN 4 AND 9 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS utilization_risk_category

FROM base;



-- 2. Quick sanity check
-- Just making sure the table populated correctly before moving on
SELECT *
FROM patient_features
LIMIT 10;

-- Sample output looks reasonable
-- A few things I checked manually:
    -- * utilization_score calculation looks correct
    -- * high medication flag appears where expected
    -- * long stay flag is being assigned correctly
    -- * risk categories aren't obviously skewed

-- Nothing jumped out as broken, so this feature set should be good enough for initial modeling experiments
