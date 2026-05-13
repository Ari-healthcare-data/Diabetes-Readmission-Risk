# Hospital Readmission Risk Analysis: Diabetes

## Project Overview

This project explores hospital readmissions for diabetes patients using the “Diabetes 130-US hospitals (1999–2008)” dataset.

The main goal is to better understand which patient or hospital-related factors may be associated with 30-day readmissions.

I originally approached this as a prediction problem, but very quickly realized the harder part is actually understanding the data itself — especially in a healthcare context where variables are messy, partially missing, and often indirectly defined.

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

Most of the early exploration for this project was done on my local system and in a Kaggle Notebook before I moved things over into this GitHub repo.

Kaggle Notebook: 
[01_eda](https://www.kaggle.com/code/datascienceam/01-eda)
[02_feature_engineering](https://www.kaggle.com/code/datascienceam/02-feature-engineering)
[03_stat_analysis](https://www.kaggle.com/code/datascienceam/03-stat-analysis)

The Kaggle notebook is where I worked through the messy part of the analysis, getting a feel for the data, testing cleaning decisions, and doing some quick visual checks to understand what was going on.

This GitHub version is a cleaner, more structured write-up of that same process, with everything organized so it’s easier to follow and reproduce.

---

## Current Progress (End of Day 3)

I ran:
- Chi-square tests for categorical variables
- T-tests for numerical variables

Key findings:
- Prior inpatient visits show the strongest association with readmission
- Emergency visits and medication count also show weaker but consistent signals
- Demographic variables (race, gender) show little to no strong association

## Next Steps

- Build baseline machine learning models (logistic regression, tree-based models)
- Eventually integrate SQL-based analysis and dashboard layer

---

## Early Observations

Some early patterns I noticed during exploratory analysis:

- Patients with more inpatient visits appear more likely to be readmitted
- Emergency visit history also seems important
- Readmitted patients had slightly longer hospital stays on average
- Several variables contain very high missingness
- Medication counts are higher among readmitted patients
- The dataset has noticeable class imbalance (~11% readmitted within 30 days)

One thing that surprised me was that the 20–30 age group showed a relatively high readmission rate. I still need to investigate whether that is meaningful or caused by something else in the data.

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

## Challenges So Far

A few real challenges that shaped how I approached this project:

- High class imbalance (~11% readmitted)
- Very high dimensional feature space after encoding
- Many categorical variables with large cardinality (especially diagnosis codes)
- Missing data is uneven and sometimes likely informative

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

- Python (pandas, numpy, scipy, sklearn) 
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
