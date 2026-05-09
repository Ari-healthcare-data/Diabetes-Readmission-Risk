# Hospital Readmission Risk Analysis for Diabetes Patients

## Project Overview

This project explores hospital readmissions for diabetes patients using the “Diabetes 130-US hospitals (1999–2008)” dataset.

The main goal is to better understand which patient or hospital-related factors may be associated with 30-day readmissions.

I wanted this project to feel closer to a real healthcare analytics workflow instead of only building a machine learning model. A lot of the work so far has focused on understanding messy hospital data, identifying data quality issues, and thinking through how hospitals might actually use this type of reporting.

---

## Business Problem

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
Diabetes 130-US hospitals for years 1999–2008

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

Kaggle Notebook: https://www.kaggle.com/code/datascienceam/01-eda-ipynb

The Kaggle notebook is where I worked through the messy part of the analysis, getting a feel for the data, testing cleaning decisions, and doing some quick visual checks to understand what was going on.

This GitHub version is a cleaner, more structured write-up of that same process, with everything organized so it’s easier to follow and reproduce.

---

## Current Progress (End of Day 1)

Completed so far:
- Created project folder structure
- Loaded dataset into Python
- Explored dataset structure and variable types
- Replaced `"?"` values with proper null values
- Identified major missing data issues
- Dropped a few non-useful variables
- Created a binary 30-day readmission target variable
- Started exploratory analysis

Still in progress:
- deeper data cleaning
- diagnosis grouping strategy
- SQL reporting layer
- dashboard planning

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
