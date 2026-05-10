# Hospital Readmission Risk Analysis: Diabetes

## Project Overview

This project explores hospital readmissions for diabetes patients using the “Diabetes 130-US hospitals (1999–2008)” dataset.

The main goal is to better understand which patient or hospital-related factors may be associated with 30-day readmissions.


I wanted this project to feel closer to a real healthcare analytics workflow instead of only building a machine learning model. A lot of the work so far has focused on understanding messy hospital data, identifying data quality issues, and thinking through how hospitals might actually use this type of reporting.

I started this project with a simple question in mind:
> Can I identify early warning signals for hospital readmission using clinical data?

But as I worked through the dataset, it became more of a data exploration and feature engineering exercise than I initially expected, mostly because the data is messy, encoded, and not very clean in its raw form.

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

Most of the early exploration for this project was done in a Kaggle Notebook before I moved things over into this GitHub repo.

Kaggle Notebook: 

[01-eda](https://www.kaggle.com/code/datascienceam/01-eda)

[02_feature_engineering](https://www.kaggle.com/code/datascienceam/02-feature-engineering)


The Kaggle notebook is where I worked through the messy part of the analysis, getting a feel for the data, testing cleaning decisions, and doing some quick visual checks to understand what was going on.

This GitHub version is a cleaner, more structured write-up of that same process, with everything organized so it’s easier to follow and reproduce.

---

## Current Progress (End of Day 2)

At this stage, I have focused mainly on data understanding and feature engineering.

### Completed so far:
- Loaded and explored dataset structure
- Cleaned missing value formatting (“?” → NaN)
- Identified and removed low-information columns
- Created binary target variable (`readmitted_30`)
- Conducted exploratory analysis on key variables
- Built full feature engineering pipeline
- Applied one-hot encoding to categorical variables
- Generated final ML-ready dataset (~2418 features)


## Next Steps

The next phase will focus on:

- statistical analysis (group comparisons, hypothesis testing)
- identifying meaningful relationships between variables and readmission
- building baseline machine learning models
- evaluating predictive performance

---

## Early Observations

Some early patterns I noticed during exploratory analysis:

- Patients with more inpatient visits appear more likely to be readmitted
- Emergency visit history also seems important
- Readmitted patients had slightly longer hospital stays on average
- Several variables contain very high missingness
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

## Tools Used

- Python
- pandas
- numpy
- Jupyter Notebook
- Excel

---

## Repository Structure

```
hospital-readmission-risk-analysis/
- README.md
- data_dictionary.md
- methodology.md
- data_understanding.md
- requirements.txt
- data/
- notebooks/
```
