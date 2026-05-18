# Hospital Readmission Risk Prediction & Utilization Analysis: Diabetes

## Project Overview

This project analyzes 30-day hospital readmissions among diabetes patients using the Diabetes 130-US hospitals (1999–2008) dataset.

What started as a fairly standard classification problem gradually turned into something a bit more interesting to me:

> Understanding what hospital readmission risk is actually capturing inside a real healthcare system.

Across exploratory analysis, statistical testing, and early modeling, a consistent pattern kept showing up:

> Patients with higher prior healthcare utilization, especially inpatient history, tend to have higher readmission risk.

That observation is not framed as causation, but it has become the central thread of the project so far.

---

## Business Problem

> What factors are associated with 30-day hospital readmissions among diabetes patients?

Hospital readmissions are an important healthcare quality metric because they can reflect:
- gaps in care coordination
- poor chronic disease management
- high patient complexity
- discharge planning issues
- increased healthcare costs

In this project, I am focusing on:
- exploring patterns associated with 30-day readmissions
- understanding utilization trends
- identifying possible risk indicators
- evaluating whether patterns are consistent across statistical + ML methods
- preparing the data for future reporting and modeling work

---

## Dataset

**Dataset:**  
[Diabetes 130-US hospitals for years 1999–2008](https://www.kaggle.com/datasets/brandao/diabetes)

**Source:**  
[Kaggle](https://www.kaggle.com/datasets/brandao/diabetes)

The dataset contains over 100,000 hospital encounters from 130 U.S. hospitals and includes:
- demographics
- diagnoses
- medications
- utilization history
- admission/discharge information
- limited lab result information

---

## Notebook Analysis Work

Most of the early exploration for this project was done on my local system and in a Kaggle Notebooks before I moved things over into this GitHub repo.

**Kaggle Notebooks:**

- [01_eda](https://www.kaggle.com/code/datascienceam/01-eda)

- [02_feature_engineering](https://www.kaggle.com/code/datascienceam/02-feature-engineering)

- [03_stat_analysis](https://www.kaggle.com/code/datascienceam/03-stat-analysis)

- [04_ modeling](https://www.kaggle.com/code/datascienceam/04-modeling)

NOTE on Reproducibility: Minor variations in results may occur due to environment differences (local vs Kaggle), but overall findings remain consistent across runs.

The Kaggle notebooks and on my local system  are where I worked through the messy part of the analysis, getting a feel for the data, testing cleaning decisions, and doing some quick visual checks to understand what was going on.

This GitHub version is a cleaner, more structured write-up of that same process, with everything organized so it’s easier to follow and reproduce.

---

## Current Project Status (End of Day 6 – Modeling Part 3)

### XGBoost Model + Deeper Evaluation

Today I implemented and evaluated an XGBoost model as part of the main modeling comparison (Logistic Regression, Random Forest, and now XGBoost).

The goal was to see whether a more powerful gradient boosting approach could meaningfully improve detection of 30-day readmissions beyond the earlier models.


### What I worked on

- Trained an XGBoost classifier on the engineered feature set (~2418 features)
- Fixed feature alignment issues between train/test splits after one-hot encoding
- Evaluated model performance using:
  - ROC-AUC
  - precision / recall
  - confusion matrix
- Compared results directly against Logistic Regression and Random Forest
- Started interpreting feature importance outputs from the boosted model

### Key takeaway from XGBoost

A clear pattern showed up:

> Even with a stronger model like XGBoost, class imbalance still dominates performance on the minority class.

This reinforced something I started noticing earlier in the project:
model complexity alone does not solve the core issue in this dataset.

The signal is there, but it is not easily translated into correct classification of readmitted patients without additional steps (threshold tuning, weighting, etc.).

---

## EDA

Early Observations:

Some early patterns I noticed during exploratory analysis:

- Patients with more inpatient visits appear more likely to be readmitted
- Emergency visit history also seems important
- Readmitted patients had slightly longer hospital stays on average
- Several variables contain very high missingness
- Medication counts are higher among readmitted patients
- The dataset has noticeable class imbalance (~11% readmitted within 30 days)

One thing that surprised me was that the 20–30 age group showed a relatively high readmission rate. I still need to investigate whether that is meaningful or caused by something else in the data.

Challenges So Far:

A few real challenges that shaped how I approached this project:

- High class imbalance (~11% readmitted)
- Very high dimensional feature space after encoding
- Many categorical variables with large cardinality (especially diagnosis codes)
- Missing data is uneven and sometimes likely informative


---

## Feature Engineering Notes

This stage ended up being more complex than expected.

Main steps:
- Dropped identifier columns (`encounter_id`, `patient_nbr`)
- Removed near-constant variables
- Encoded categorical variables using one-hot encoding
- Handled missing values implicitly through encoding

### Key challenge:
One-hot encoding significantly increased feature space (~2418 columns), mainly due to:
- diagnosis codes (high cardinality)
- medical specialty
- medication variables

This is something I may revisit later if model performance or interpretability becomes an issue.

---

Statistical Analysis Findings

I used:
- Chi-square tests for categorical variables
- T-tests for numerical variables

Strongest findings:
- Prior inpatient visits had the clearest relationship with readmission
- Utilization-related variables consistently outperformed demographics
- Length of stay was statistically significant but practically smaller than expected
- Large sample size produced many small p-values, which made practical interpretation important

One thing I started thinking more about during this phase:

statistical significance does not automatically mean healthcare importance

That became increasingly important as I move throughout the project.

---

## Limitations

This is important to acknowledge:

- Readmission definition is simplified into a binary target
- No distinction between planned vs unplanned readmissions
- No time-series structure (all data treated as static snapshots)
- Potential confounding between severity and utilization variables
- Dataset reflects hospital systems, not just patient health

---

## Tools Used

- Python (pandas, numpy, scipy, sklearn, matplotlib, seaborn) 
- Jupyter Notebook
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
```

Note: The fully encoded feature dataset (`diabetic_features.csv`) is not included in the repository due to file size constraints. It can be recreated by running `02-feature-engineering.ipynb`.
