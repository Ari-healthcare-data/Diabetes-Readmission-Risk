# Diabetes Hospital Readmission Prediction, Risk Stratification & Utilization Analysis

## Project Overview

This project analyzes 30-day hospital readmissions among diabetes patients using the Diabetes 130-US hospitals (1999–2008) dataset.

What started as a fairly standard machine learning classification problem gradually turned into a broader healthcare analytics question:

> What hospital readmission risk is actually capturing inside a healthcare system?

Across exploratory analysis, statistical testing, and early modeling, a consistent pattern kept showing up:

> Patients with higher prior healthcare utilization, particularly inpatient utilization, consistently exhibit higher readmission risk

While this project does not establish causation, that observation became the central analytical theme and ultimately shaped both the modeling approach and dashboard design.

The final result is a healthcare analytics workflow that combines:

- Python-based data analysis and machine learning
- PostgreSQL feature engineering and risk scoring
- Power BI dashboard development
- Executive-style healthcare reporting

---

## Table of Contents

- [Executive Summary](/executive_summary.md)
- [Dataset](#dataset)
- [Project Workflow](#project-workflow)
  - [Phase 1: Python Analytics](#phase-1-python-analytics)
  - [Phase 2: SQL Analytics](#phase-2-sql-analytics)
- [Key Findings](#key-findings)
- [Power BI Dashboard Preview](#power-bi-dashboard-preview)
- [Dashboard Development Notes](#dashboard-development-notes)
- [Limitations](#limitations)
- [Tools Used](#tools-used)
- [Repository Structure](#repository-structure)
- [Final Reflection](#final-reflection)

---

Hospital readmissions are commonly used as a healthcare quality and operational performance metric.

Higher readmission rates may reflect:

- care coordination challenges
- chronic disease complexity
- discharge planning gaps
- healthcare access issues
- increased operational costs

The primary question explored throughout this project is:

> Which patient characteristics and utilization patterns are most strongly associated with 30-day hospital readmissions?

---

## Dataset

**Dataset:**  
[Diabetes 130-US hospitals for years 1999–2008](https://www.kaggle.com/datasets/brandao/diabetes)

**Source:**  
[Kaggle](https://www.kaggle.com/datasets/brandao/diabetes)

Dataset characteristics:

- ~101,000 hospital encounters
- ~71,500 unique patients
- 130 U.S. hospitals
- Diabetes-focused patient population

Available data includes:

- demographics
- diagnoses
- medications
- utilization history
- admission information
- discharge information
- selected laboratory results

---

## Project Workflow



### Phase 1: Python Analytics

#### Exploratory Data Analysis

Kaggle Notebooks: [01_eda](https://www.kaggle.com/code/datascienceam/diabetes-readmission-risk-01-eda)


Key activities:

- Data quality assessment
- Missing value analysis
- Readmission distribution analysis
- Utilization trend exploration
- Clinical variable exploration

#### Feature Engineering

Kaggle Notebooks: [02_feature_engineering](https://www.kaggle.com/code/datascienceam/diabetes-readmission-risk-02-feature-engineering)

Key steps:

- Removed identifier columns
- One-hot encoded categorical variables
- Built modeling dataset
- Created ~2,418 engineered features

Challenge:

High-cardinality diagnosis codes dramatically expanded feature space and increased model complexity.

#### Statistical Analysis

Kaggle Notebooks: [03_stat_analysis](https://www.kaggle.com/code/datascienceam/diabetes-readmission-risk-03-stat-analysis)

Methods used:

- Chi-square testing
- Independent t-tests
- Group comparisons

Primary finding:

Utilization-related variables consistently demonstrated stronger relationships with readmission than demographic variables.


#### Machine Learning Modeling

Kaggle Notebooks: [04_ modeling](https://www.kaggle.com/code/datascienceam/diabetes-readmission-risk-04-modeling)


Models evaluated:

- Logistic Regression
- Random Forest
- XGBoost

Results:

| Model | Key Observation |
|-------|-----------------|
| Logistic Regression	| Established baseline signal |
| Random Forest | Limited minority-class recall |
| XGBoost | Best ranking performance (~0.69 ROC-AUC)|

One important realization:

Threshold selection often had a larger impact on healthcare usefulness than model choice itself.

Note on Reproducibility: Minor variations in results may occur due to environment differences (local vs Kaggle), but overall findings remain consistent across runs.

### Phase 2: SQL Analytics

Following the Python analysis, the project shifted into PostgreSQL to validate findings and build reusable reporting layers.

SQL:

- `01_data_exploration.sql`
- `02_readmission_metrics.sql`
- `03_utilization_analysis.sql`
- `04_risk_cohorts.sql`
- ` 05_feature_engineering.sql`
- `06_dashboard_views.sql`
- `07_patient_risk_summary.sql`

A patient-level aggregation layer was created:

`patient_risk_summary`

This table became the primary reporting source for Power BI.

---

## Why I Chose This Project

I chose this dataset because it sits at the intersection of healthcare, machine learning, and operational decision-making.

Readmissions are often discussed as a predictive modeling problem, but they also raise practical questions around resource allocation, care coordination, and patient complexity.

I wanted to see whether the patterns identified by machine learning models would remain consistent across statistical analysis, SQL-based reporting, and business-facing dashboards.

---

## Key Findings

### 1. Prior utilization is the strongest signal

Across every stage of the project:

- EDA
- Statistical testing
- Logistic Regression
- Random Forest
- XGBoost
- SQL validation
- Dashboard reporting

The same pattern consistently appeared:

> Patients with greater prior healthcare utilization exhibit substantially higher readmission risk.

#### 2. Inpatient history dominates risk

One of the strongest observed relationships:

| Prior Inpatient Visits |Readmission Rate |
|------------------------|-----------------|
| 0 Visits | ~8% |
| 5+ Visits | 30%+ |

This relationship remained stable regardless of analytical method.

#### 3. Demographics contributed relatively little signal

Variables such as:

- gender
- race

showed comparatively weak relationships with readmission risk.

Utilization-based variables consistently provided stronger separation.

#### 4. Readmission appears linked to healthcare interaction patterns

One interpretation that emerged throughout the project:

> Readmission risk may reflect recurring healthcare system interaction patterns as much as individual patient characteristics.

This remains an observational finding rather than a causal conclusion.

---

## Power BI Dashboard Preview

One project goal was translating analytical findings into a format that resembles how healthcare leaders might actually consume information.

The final dashboard consists of four pages.

### Page 1: Executive Clinical Overview

Provides a high-level summary of:

- patient population
- readmission rates
- utilization metrics
- medication burden
- risk distribution

![Executive Clinical Overview](images/page_1_overview.png)


### Page 2:  Patient Risk Stratification

Focuses on:

- risk segmentation
- utilization comparisons
- length-of-stay trends
- medication burden

![Patient Risk Stratification](images/page_2_patient_risk_stratification.png)

### Page 3: Clinical Risk Drivers

Explores variables most strongly associated with elevated risk.

Highlights:

- utilization score differences
- inpatient utilization
- encounter frequency
- readmission outcomes

![Clinical Risk Drivers](images/page_3_clinical_risk_drivers.png)

### Page 4: Executive Summary

Consolidates:

- major KPIs
- risk segmentation
- operational implications
- stakeholder-focused findings

![Executive Summary](images/page_4_executive_summary.png)

---

## Dashboard Development Notes

Building the reporting layer ended up being one of the more challenging parts of the project.

A large portion of the work involved:

- designing SQL aggregation logic
- creating patient-level risk tables
- troubleshooting Power BI relationships
- validating KPI calculations
- translating technical findings into stakeholder-friendly metrics

---

## Limitations

Several important limitations should be acknowledged:

- Readmission simplified into a binary target
- Planned vs unplanned readmissions not separated
- No temporal progression modeling
- Potential confounding between utilization and disease severity
- Encounter-level data structure introduces repeat-patient effects
- External validation not performed

Results should therefore be interpreted as exploratory and operational rather than causal.

---

## Tools Used

- Python (pandas, numpy, scipy, sklearn, matplotlib, seaborn) 
- Jupyter Notebook
- PostgreSQL (pgAdmin4)
- Excel

---

## Repository Structure

```
diabetes-readmission-risk/

- README.md
- data_dictionary.md
- methodology.md
- data_understanding.md
- requirements.txt

- data/
- notebooks/
- sql/
- images/
```

Note: The fully encoded feature datasets are not included in the repository due to file size constraints on GitHub. They can be recreated by running the Jupyter Notebooks.

---

## Final Reflection

The most interesting outcome of this project was not model performance.

It was seeing the same utilization-driven signal survive every validation layer:

- exploration
- statistics
- machine learning
- SQL analysis
- dashboard reporting

The project gradually shifted from:

"Can I predict readmission?"

to

"What patterns consistently appear among patients who return to the hospital?"

That question ended up being far more interesting—and far more useful from a healthcare operations perspective—than I expected when I started.
