# Data Dictionary: Diabetes Readmission Dataset

This document is a simplified explanation of the dataset based on my exploration so far. I wrote this while working through the data, so it reflects my current understanding rather than a formal clinical definition. The goal here is just to keep track of what I understood at each stage, not to recreate the [Description PDF documentation]( https://www.kaggle.com/datasets/brandao/diabetes)  that came with the dataset.



Dataset: [Diabetes 130-US hospitals (1999–2008)](https://www.kaggle.com/datasets/brandao/diabetes)

---

## Identifiers

**encounter_id**  
A unique ID for each hospital encounter.  
Not really used for analysis perse, just helps keep records distinct.
Not used for modeling

**patient_nbr**  
A unique identifier for each patient.  
This one is important because some patients appear multiple times, so it helps when thinking about repeat visits.

---

## Demographics

**race**  
Patient race category (e.g., Caucasian, AfricanAmerican, etc.).  
There is a small amount of missing data here, nothing extreme but still noticeable.

**gender**  
Patient gender. Mostly Male/Female, but there are a few "Unknown/Invalid" entries that I left as-is for now.

**age**  
Age is grouped into bins instead of exact values (like [50–60), [60–70), etc.).  
At first this felt limiting, but I think it actually simplifies analysis a bit.

---

## Admission Information

**admission_type_id**  
Encodes the type of admission (emergency, elective, urgent, etc.).  
This is numeric but really represents categories.

**discharge_disposition_id**  
Where the patient went after discharge (home, transfer, etc.).  
Feels like an important variable but a bit messy without proper decoding.

**admission_source_id**  
Where the patient came from before admission (ER, referral, transfer).  
Another encoded categorical field.

**time_in_hospital**  
Length of stay in days.  
Straightforward numeric variable and one of the first things I looked at during EDA.

---

## Utilization History

These variables are basically counts of prior healthcare usage.

**number_outpatient**  
Number of outpatient visits in the year before admission.

**number_emergency**  
Number of emergency room visits in the year before admission.

**number_inpatient**  
Number of inpatient admissions in the year before this encounter.

This group stood out early because they seem loosely connected to readmission risk.

---

## Clinical Information

**diag_1, diag_2, diag_3**  
Diagnosis codes (ICD-9 format).  
These are messy in their raw form with lots of unique values and not immediately interpretable without grouping.

**number_diagnoses**  
Total number of diagnoses recorded for the encounter.  
Feels like a proxy for patient complexity, but I haven’t fully validated that yet.

---

## Lab Results (high missingness area)

**A1Cresult**  
Indicates long-term blood glucose control.  
Very important clinically, but missing in most rows (~80%+), so I’m still deciding how much weight to give it.

**max_glu_serum**  
Serum glucose test result.  
Even more missing than A1Cresult in many cases.

At this stage, I’m keeping them in the dataset but treating them carefully because missingness might itself carry meaning.

---

## Medications

There are multiple medication-related variables (metformin, insulin, etc.).

Each one usually takes values like:
- No
- Steady
- Up
- Down

This basically reflects whether medication dosage was changed during the encounter.

I haven’t fully unpacked this section yet, but it feels like it could be important for treatment patterns.

---

## Administrative Variables

**payer_code**  
Insurance or payer category.  
Quite a bit of missing data here, so I’m not sure yet how useful it will be.

**medical_specialty**  
Specialty of the admitting physician.  
High number of unique values and lots of missingness. This one may need grouping if I use it later.

---

## Target Variable

**readmitted**  
Original readmission label:
- "<30" = readmitted within 30 days  
- ">30" = readmitted after 30 days  
- "NO" = not readmitted  

**readmitted_30**  
A binary version I created for analysis:
- 1 = readmitted within 30 days  
- 0 = otherwise  

This simplifies the problem into a standard classification setup.

---

## Data Cleaning Decisions (so far, Day 1)

A few things I removed early on:

- `weight` is almost completely missing (~97%), not usable in current form  
- `examide` and `citoglipton`  only have one unique value each, so they don’t really add information  

Everything else is still under consideration depending on how analysis evolves.

---

## A few honest notes

Some variables here are clearly more meaningful clinically than others, but in practice, usefulness depends a lot on completeness and context.

Right now I’m trying not to drop too much too early, but also not overcomplicate things with variables that are mostly empty or hard to interpret.

This will likely evolve as I move into modeling and deeper analysis. 