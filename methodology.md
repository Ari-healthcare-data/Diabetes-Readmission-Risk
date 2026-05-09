# Methodology: Work in Progress

This document outlines how I approached the project so far. It’s still evolving, and I expect it to change quite a bit as I move deeper into the analysis and eventually into modeling and dashboard work.

Right now it mostly reflects what I’ve actually done and how I’ve been thinking through the dataset step by step, rather than a strict or fully finalized methodology.

---

## Overall approach

The general idea for this project is to treat it like a real healthcare analytics workflow rather than just a modeling exercise.

So instead of jumping straight into machine learning, I started with:
- understanding the dataset
- cleaning obvious issues
- doing exploratory analysis
- thinking about how this would actually be used in a hospital reporting context

The modeling part will come later, but I wanted the structure to feel realistic first.

---

## Step 1 - Data loading and initial inspection

I started by loading the dataset into Python using pandas and just trying to get a feel for it.

Typical first checks:
- shape of the dataset
- column names
- data types
- a quick look at the first few rows

Nothing fancy here, just trying to understand what I’m working with before touching anything.

---

## Step 2 - Cleaning (early stage)

The first real issue I ran into was missing data being encoded as “?” instead of proper null values.

So I replaced those with NaN so I could actually work with them properly.

After that, I started looking at missingness more seriously and realized some columns were almost entirely incomplete.

At this point I made a few early decisions:

- removed `weight` because it was ~97% missing (not usable in any meaningful way)
- removed `examide` and `citoglipton` because they had only one unique value each (no analytical value)

I didn’t want to over-clean at this stage, so I kept most variables for now and will revisit later if needed.

---

## Step 3 - Defining the target variable

The dataset originally has three readmission categories:
- `<30`
- `>30`
- `NO`

For this project, I converted it into a binary target:

- 1 = readmitted within 30 days
- 0 = otherwise

This simplifies the problem into a standard classification setup focused specifically on early readmissions.

I’m aware this merges two different groups (`>30` and `NO`), but for this stage of the project it makes the analysis more manageable.

I may revisit this later if more nuance is needed.

---

## Step 4 - Exploratory analysis (EDA)

Most of the work so far has been exploratory.

I’ve been looking at:
- distributions of key variables
- missing data patterns
- basic comparisons between readmitted vs not readmitted groups
- early correlations and trends

Nothing too advanced yet,  mostly trying to understand what actually matters in the dataset.

Some early things I noticed:
- prior inpatient visits seem linked to higher readmission risk
- emergency visits show a similar pattern
- length of stay is slightly higher for readmitted patients
- medication counts are also a bit higher in that group

These are not strong conclusions yet, just early signals.

---

## Step 5 - Thinking ahead to SQL layer

I haven’t built the SQL part yet, but I’m planning to use PostgreSQL to simulate more of a hospital reporting environment.

The idea is to eventually build queries around things like:
- readmission rates by patient group
- utilization summaries
- hospital-level aggregations

Right now this is still in the planning stage.

---

## Step 6 - Statistical analysis (planned)

I haven’t started this properly yet, but the intention is to use a mix of:
- basic group comparisons
- correlation checks
- possibly logistic regression later on

I don’t want to overcomplicate this stage. I think the key is just to support the exploratory findings rather than force complex methods too early.

---

## Step 7 - Dashboard development (planned)

Eventually I plan to build a dashboard in either Power BI or Tableau Public.

The goal is to simulate something closer to what a healthcare analytics team might actually use, such as:
- readmission monitoring
- patient utilization trends
- high-level KPI tracking

This will likely come after the SQL layer is more developed.

---

## Known limitations

There are a few limitations in the dataset that I’m aware of from early on:

- readmission is only categorical, not exact timing
- a lot of missing data in clinically important variables
- possible differences in coding practices across hospitals
- limited context around patient history outside the dataset

Because of this, I’m treating results as exploratory and descriptive, not causal.

---

## Closing notes (for now)

This methodology will definitely evolve as I go. Right now it’s mostly focused on building a structured approach rather than rushing into modeling.

The main goal at this stage has been to understand the data properly and avoid making assumptions too early. 