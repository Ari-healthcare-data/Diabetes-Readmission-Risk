-- Project: Hospital Readmission Risk Prediction: Diabetes
-- File: 06_dashboard_views.sql
-- Purpose: Create dashboard-friendly views for Power BI (KPI + risk + utilization trends)
-- Notes: Some of the thresholds used below are intentionally simple for useful dashboard outputs than optimizing every business rule
-- Author: Ari M.



-- 1. BASIC KPI SUMMARY (overall hospital performance)
-- Gives a quick summary of volume, readmissions, utilization, and LOS
DROP VIEW IF EXISTS vw_kpi_summary;

CREATE VIEW vw_kpi_summary AS
SELECT
    COUNT(*) AS total_patients,
    
    ROUND(AVG(readmitted_30::numeric), 4) AS readmission_rate,
    SUM(readmitted_30) AS total_readmitted,

    -- Rounded mostly because Power BI cards don't need extra decimals
    ROUND(AVG(number_inpatient), 2) AS avg_inpatient_visits,
    ROUND(AVG(number_emergency), 2) AS avg_emergency_visits,
    ROUND(AVG(number_outpatient), 2) AS avg_outpatient_visits,
    ROUND(AVG(num_medications), 2) AS avg_medications,
    ROUND(AVG(time_in_hospital), 2) AS avg_length_of_stay

FROM diabetic_data;


-- Quick check before wiring into dashboard visuals
SELECT *
FROM vw_kpi_summary;

-- Sample output looked reasonable when compared back to the raw data
-- Readmission rate also matched earlier EDA results pretty closely



-- 2. Simple Risk Groups
-- Using inpatient history as a simple segmentation layer
-- Earlier analysis suggested inpatient utilization was one of the stronger signals associated with readmission
DROP VIEW IF EXISTS vw_risk_groups;

CREATE VIEW vw_risk_groups AS
SELECT
    CASE
        WHEN number_inpatient >= 3 THEN 'High inpatient usage (3+)'
        WHEN number_inpatient BETWEEN 1 AND 2 THEN 'Moderate inpatient usage (1–2)'
        ELSE 'No inpatient history'
    END AS risk_group,

    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS total_readmitted,
    
    ROUND(AVG(readmitted_30::numeric), 4) AS readmission_rate

FROM diabetic_data
GROUP BY 1;


-- Just making sure the grouping logic behaves the way I expect
SELECT *
FROM vw_risk_groups;

-- One thing I noticed during review:
    -- readmission rates increase fairly consistently across the three groups, which was encouraging since the segmentation is intentionally simple



-- 3. Inpatient Utilization Trend
-- Wanted a view that could be plotted directly in Power BI for line charts and trend visuals
DROP VIEW IF EXISTS vw_utilization_trends;

CREATE VIEW vw_utilization_trends AS
SELECT
    number_inpatient,
    COUNT(*) AS total_patients,
    
    ROUND(AVG(readmitted_30::numeric), 4) AS readmission_rate

FROM diabetic_data
GROUP BY number_inpatient
ORDER BY number_inpatient;


-- Quick peek before charting
SELECT *
FROM vw_utilization_trends
LIMIT 15;

-- Rates generally trend upward as inpatient visits increase
-- There is more volatility at the extreme end because patient counts get small



-- 4. Driver Snapshot
-- Not meant to be a formal statistical analysis
-- Just a quick side-by-side look at simple correlations
DROP VIEW IF EXISTS vw_driver_snapshot;

CREATE VIEW vw_driver_snapshot AS
SELECT
    'Inpatient Visits' AS factor,
    ROUND(CORR(number_inpatient, readmitted_30)::numeric, 4) AS correlation_strength
FROM diabetic_data

UNION ALL

SELECT
    'Emergency Visits',
    ROUND(CORR(number_emergency, readmitted_30)::numeric, 4)
FROM diabetic_data

UNION ALL

SELECT
    'Outpatient Visits',
    ROUND(CORR(number_outpatient, readmitted_30)::numeric, 4)
FROM diabetic_data

UNION ALL

SELECT
    'Medication Count',
    ROUND(CORR(num_medications, readmitted_30)::numeric, 4)
FROM diabetic_data;


-- Quick review
SELECT *
FROM vw_driver_snapshot;

-- Correlations are fairly small overall, which isn't surprising
-- Inpatient visits still stand out compared to the other variables



-- 5. Utilization Distribution
-- Similar to the utilization trend view above, but kept separately because
-- I ended up using it in a few different visuals while experimenting
DROP VIEW IF EXISTS vw_utilization_distribution;

CREATE VIEW vw_utilization_distribution AS
SELECT
    number_inpatient,
    COUNT(*) AS patient_count,
    
    ROUND(AVG(readmitted_30::numeric), 4) AS readmission_rate

FROM diabetic_data
GROUP BY number_inpatient;


-- Quick preview
SELECT *
FROM vw_utilization_distribution
LIMIT 15;

-- Distribution is heavily concentrated at zero inpatient visits, which matches what I saw earlier during EDA



-- 6. High Risk Patient Flagging
-- Just trying to identify a few patient groups that seem worth paying closer attention to based on utilization and complexity indicators
DROP VIEW IF EXISTS vw_high_risk_patients;

CREATE VIEW vw_high_risk_patients AS
SELECT
    patient_nbr,
    number_inpatient,
    num_medications,
    time_in_hospital,
    readmitted_30,

    CASE
        WHEN number_inpatient >= 3
             AND (num_medications >= 15 OR time_in_hospital >= 7)
        THEN 'High Risk (Multi-Factor)'

        WHEN number_inpatient >= 3
        THEN 'High Risk (Inpatient Driven)'

        WHEN number_inpatient = 2
             AND num_medications >= 20
        THEN 'Moderate-High Risk'

        ELSE 'Not High Risk'
    END AS risk_segment

FROM diabetic_data;


-- Spot check a few rows
SELECT *
FROM vw_high_risk_patients
LIMIT 10;

-- Mostly checking that the CASE logic is assigning categories correctly

-- Curious what the highest utilization patients look like
SELECT *
FROM vw_high_risk_patients
ORDER BY number_inpatient DESC
LIMIT 10;

-- Some patient IDs appear multiple times because the dataset is encounter-based, which is expected

-- Looking only at patients that actually trigger one of the risk rules
SELECT *
FROM vw_high_risk_patients
WHERE risk_segment != 'Not High Risk'
ORDER BY number_inpatient DESC, num_medications DESC
LIMIT 10;

-- Useful for validating that the highest-risk records are ending up where expected

-- Quick count by segment
SELECT risk_segment, COUNT(*)
FROM vw_high_risk_patients
GROUP BY risk_segment;

-- Most encounters remain in the baseline group, which is probably what I'd expect



-- 7. Relative Risk View
-- Compares readmission rates against the overall baseline rate
-- I liked this view because the multiplier is pretty easy to explain
DROP VIEW IF EXISTS vw_relative_risk;

CREATE VIEW vw_relative_risk AS
SELECT
    'High inpatient (3+)' AS group_name,
    ROUND(
        AVG(readmitted_30::numeric) /
        (SELECT AVG(readmitted_30::numeric) FROM diabetic_data),
        2
    ) AS risk_multiplier
FROM diabetic_data
WHERE number_inpatient >= 3

UNION ALL

SELECT
    'Moderate inpatient (1–2)',
    ROUND(
        AVG(readmitted_30::numeric) /
        (SELECT AVG(readmitted_30::numeric) FROM diabetic_data),
        2
    )
FROM diabetic_data
WHERE number_inpatient BETWEEN 1 AND 2

UNION ALL

SELECT
    'No inpatient history',
    ROUND(
        AVG(readmitted_30::numeric) /
        (SELECT AVG(readmitted_30::numeric) FROM diabetic_data),
        2
    )
FROM diabetic_data
WHERE number_inpatient = 0;



SELECT *
FROM vw_relative_risk
LIMIT 10;

-- High inpatient (3+):	2.30
-- Moderate inpatient (1–2):	1.27
-- No inpatient history:	0.76

-- Interpreting the multiplier:
-- 1.00 = same as the overall readmission rate
-- 2.00 = roughly double the overall readmission rate
-- 0.50 = roughly half the overall readmission rate


-- 8. Risk Scoring Layer
-- Wanted a numeric score instead of only categories
-- Makes ranking and filtering a lot easier in Power BI
DROP VIEW IF EXISTS vw_risk_scoring;

CREATE VIEW vw_risk_scoring AS
SELECT
    patient_nbr,
    number_inpatient,
    num_medications,
    time_in_hospital,
    number_emergency,
    readmitted_30,

    -- Very simple weighted score.
    -- Weights were chosen based mostly on patterns from EDA and not through any formal optimization process
    (
        (number_inpatient * 3) +
        (num_medications * 0.5) +
        (time_in_hospital * 0.5) +
        (number_emergency * 2)
    ) AS risk_score

FROM diabetic_data;


SELECT *
FROM vw_risk_scoring
LIMIT 10;

-- Mainly checking for obvious issues like negative values, weird outliers, or scoring logic mistakes



-- 9. Risk Segment Validation
-- Want to see whether the segment definitions actually separate patients into groups with meaningfully different outcomes
DROP VIEW IF EXISTS vw_risk_validation;

CREATE VIEW vw_risk_validation AS
SELECT
    risk_segment,
    COUNT(*) AS patients,
    ROUND(AVG(readmitted_30::numeric), 4) AS actual_readmission_rate
FROM vw_high_risk_patients
GROUP BY risk_segment;



SELECT *
FROM vw_risk_validation;

-- If readmission rates were nearly identical across segments, that would be a sign that the rules need rethinking
-- The separation isn't perfect, but there is a noticeable difference between baseline patients and the higher-risk groups



-- 10. Risk Percentile Ranking
-- Converts the risk score into deciles so patients can be prioritized
-- This ended up being one of the more useful dashboard views
DROP VIEW IF EXISTS vw_risk_percentiles;

CREATE VIEW vw_risk_percentiles AS
SELECT
    patient_nbr,
    risk_score,

    NTILE(10) OVER (ORDER BY risk_score DESC) AS risk_decile,

    CASE
        WHEN NTILE(10) OVER (ORDER BY risk_score DESC) = 1 THEN 'Top 10% Risk'
        WHEN NTILE(10) OVER (ORDER BY risk_score DESC) <= 3 THEN 'High Risk (Top 30%)'
        WHEN NTILE(10) OVER (ORDER BY risk_score DESC) <= 7 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_priority_band

FROM vw_risk_scoring;


SELECT *
FROM vw_risk_percentiles
LIMIT 10;

-- Deciles are useful because they force a ranking even when score cutoffs are somewhat arbitrary



-- 11. FINAL DASHBOARD BASE VIEW
-- This became the main reporting view that I connect to Power BI
-- Combines utilization metrics, outcomes, and the risk score in one place
DROP VIEW IF EXISTS vw_dashboard_base;

CREATE VIEW vw_dashboard_base AS
SELECT
    p.patient_nbr,

    p.number_inpatient,
    p.number_emergency,
    p.number_outpatient,
    p.num_medications,
    p.time_in_hospital,
    p.readmitted_30,

    s.risk_score,

    CASE
        WHEN s.risk_score >= 25 THEN 'Very High Risk'
        WHEN s.risk_score >= 15 THEN 'High Risk'
        WHEN s.risk_score >= 8 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_score_segment

FROM diabetic_data p
LEFT JOIN vw_risk_scoring s
    ON p.patient_nbr = s.patient_nbr;

-- Quick look at the final dataset
SELECT *
FROM vw_dashboard_base
LIMIT 10;

-- This is usually the point where I switch over to Power BI
-- and start building visuals instead of writing SQL


-- Explore structure and row counts
SELECT *
FROM vw_dashboard_base;

-- Total rows shown in editor preview will usually be limited, so I like to verify the actual row count separately


-- Total encounter rows
SELECT COUNT(*)
FROM vw_dashboard_base;

-- 229892


-- Unique patients
SELECT COUNT(DISTINCT patient_nbr)
FROM vw_dashboard_base;

-- 71518
-- Useful reminder:
    -- Encounter count and patient count are not the same thing why the total row count is much larger than the distinct patient count
