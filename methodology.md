# Methodology

This document summarizes the end-to-end methodology used throughout the project, from data exploration and feature engineering through modeling, SQL-based analytics, and dashboard development.

---

## Overall approach

The general idea for this project is to treat it like a real healthcare analytics workflow rather than just a modeling exercise.

Instead of jumping directly into modeling, I tried to follow a more realistic analytics workflow:

1. Understand the dataset  
2. Clean and structure the data  
3. Explore patterns  
4. Engineer features  
5. Prepare for statistical analysis and modeling  

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

## Step 2 - Cleaning 

Key cleaning steps:
- Replaced “?” with NaN  
- Identified missing value patterns  
- Removed near-empty or low-information variables:
  - weight (too much missing data)
  - examide
  - citoglipton  

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

At this stage, I explored:
- distributions of key variables  
- missing data patterns  
- group comparisons (readmitted vs not readmitted)  
- early relationships between variables  

Nothing too advanced yet,  mostly trying to understand what actually matters in the dataset.

Findings were mostly descriptive, not statistical.

Some early things I noticed:
- prior inpatient visits seem linked to higher readmission risk
- emergency visits show a similar pattern
- length of stay is slightly higher for readmitted patients
- medication counts are also a bit higher in that group

These are not strong conclusions yet, just early signals.

---

## Step 5 - Feature Engineering

This was the most time-intensive part so far.

Steps included:
- Removing identifier columns  
- Handling categorical variables  
- Applying one-hot encoding  

### Outcome:
- Dataset expanded to ~2418 features  
- High dimensionality mainly driven by:
  - diagnosis codes  
  - medical specialty  
  - medication variables  

This introduced tradeoffs between simplicity and interpretability.

---

## Step 6 - Statistical analysis (planned)

Performed hypothesis testing to validate observed patterns:

- Chi-square tests (categorical variables)
- T-tests (numerical variables)

Key findings:
- inpatient history is strongly associated with readmission
- utilization variables are more predictive than demographics
- many small but statistically significant effects exist due to dataset size

Important realization:
> statistical significance does not always equal practical importance

---

## Step 7 - Modeling

### 7a - Baseline Predictive Modeling

#### Baseline model

Current baseline:
- Logistic Regression

Reason:
- interpretable
- strong baseline comparison
- easier to understand feature relationships


### 7b - Random Forest

Also trained a Random Forest model to see if a non-linear, tree-based approach would capture more signal in the data.

- Tree-based model for capturing non-linear relationships
- No feature scaling required
- Used `class_weight="balanced"` to handle class imbalance

#### Results:
- ROC-AUC: ~0.65
- Recall: ~0.01

Even though the ROC-AUC improved slightly compared to Logistic Regression, the model performed significantly worse at identifying readmitted patients.

Most predictions ended up concentrated in the majority class, which suggests that class imbalance is still dominating the learning process.


### 7c - Threshold Tuning

After evaluating the Random Forest output, I tested threshold tuning instead of relying only on the default 0.5 cutoff.

Adjusted threshold:
- 0.50 → 0.30

#### Why this mattered

The default threshold was heavily favoring the majority class.

Lowering the threshold increased sensitivity toward the minority class.

#### Result
- recall improved modestly
- precision decreased
- more high-risk patients were identified

The numerical improvement itself was relatively small.

But conceptually, this stage became very important because it shifted the project toward:
- model interpretation
- healthcare tradeoffs
- and decision-focused evaluation

This stage reinforced something important:

model quality depends not only on the algorithm, but also on:
- how predictions are interpreted
- what errors matter most
- and the real-world objective.

In healthcare:
- false negatives may carry significant consequences
- while false positives may sometimes be more acceptable

That tradeoff became much more tangible during threshold tuning.

### 7d - XGBoost

After building Logistic Regression and Random Forest models, I added XGBoost as a third modeling approach to see whether a more advanced boosting method could meaningfully improve performance on this dataset.

At this stage, the goal wasn’t just “better accuracy”, it was more about checking whether a stronger model would actually change the underlying pattern I had been seeing, or just reinforce the same story with slightly better metrics.

#### Model setup

I trained an XGBoost classifier on the full engineered dataset (~2418 features), using the same train/test split as previous models to keep comparisons consistent.

Key steps included:

- training XGBoost on the same feature set used for Logistic Regression and Random Forest
- resolving feature alignment issues caused by one-hot encoding
- keeping preprocessing consistent across all models for fair comparison
- evaluating using:
  - ROC-AUC
  - precision
  - recall
  - confusion matrix

I didn’t do heavy hyperparameter tuning at this stage — I wanted a relatively “baseline XGBoost” to compare behavior rather than optimize it too aggressively.


#### Results 

- XGBoost produced the best ROC-AUC so far (~0.69 range)
- however, recall for the minority class remained very low
- predictions were still heavily biased toward the majority class
- performance still depended more on threshold choice than model choice itself

So while the ranking ability improved, the actual ability to *catch readmitted patients* didn’t improve nearly as much.


#### Important observation: stronger models ≠ better decisions

One thing that became clearer after introducing XGBoost is that model strength (in terms of ROC-AUC) does not directly translate into better real-world usefulness in this problem.

Even though XGBoost ranked patients better overall, it still struggled to identify enough positive cases without adjusting the decision threshold.

This reinforced a key point that has been showing up throughout modeling:

> improving the model does not automatically solve class imbalance.

The imbalance problem is still doing most of the heavy lifting in terms of shaping predictions.


#### Feature consistency check

One encouraging thing was that feature importance patterns stayed very consistent even with XGBoost.

The same variables kept appearing across all models:

- `number_inpatient`
- `number_emergency`
- medication-related variables (especially insulin changes)
- overall utilization intensity features

This consistency across:
- EDA
- statistical testing
- Logistic Regression
- Random Forest
- XGBoost

gives more confidence that these signals are not model-specific artifacts, but actually stable patterns in the dataset.


#### Interpretation update

At this point, my understanding has become more structured:

> readmission risk appears strongly associated with prior healthcare utilization, but predicting it accurately at the individual level is still limited by class imbalance and overlapping patient factors.

This is not a causal statement, but it is a consistent pattern across all methods used so far.


#### What this changed in my thinking

XGBoost didn’t drastically change the direction of the project, but it did reinforce something important:

- model complexity is not the main bottleneck here
- the main challenges are:
  - imbalance
  - feature overlap
  - and threshold sensitivity

### 7e - Precision-Recall Analysis

Instead of relying only on ROC-AUC or accuracy, I started focusing more directly on:
- minority-class behavior
- recall tradeoffs
- threshold sensitivity

Built:
- precision-recall curves
- threshold comparisons

Main realization:
> threshold choice affected outcomes almost as much as model choice itself.

This shifted the project away from:
- “which model wins?”
and more toward:
- “which prediction behavior is actually useful?”

### Step 7f - Risk Scoring & Decision Support Layer

After evaluating Logistic Regression, Random Forest, and XGBoost, I wanted to move beyond simple classification outputs and explore how model predictions could be translated into a more practical decision-support format.

##### Risk Distribution Analysis

A distribution plot was generated to examine how predicted risk scores were spread across the population.

Several patterns were noticeable:

- most patients clustered in lower-risk ranges
- medium-risk patients formed a smaller segment
- high-risk patients represented a relatively small proportion of encounters

This behavior was generally consistent with the underlying class imbalance observed throughout the project.


---

## Step 8 - SQL

### 8.1 - SQL validation layer (`01_data_exploration.sql`)

This is a new phase added in Day 10.

What changed:

Instead of only trusting Python outputs, I started validating patterns using SQL directly on the database.

First SQL checks:
- total row count (101,766)
- readmission rate (~11%)
- inpatient visit distributions
- age distributions

Key SQL insight at this point:

A consistent pattern emerged:

> readmission rate increases steadily with prior inpatient visits

This confirmed earlier findings from:
- EDA
- statistical testing
- modeling

### 8.2 - KPIs & Readmission Metrics (`02_readmission_metrics.sql`)
Focused on:
- overall readmission KPIs
- demographic readmission breakdowns
- class imbalance metrics
- age/gender/race comparisons

#### Known Challenges

Main analytical challenges:
- class imbalance
- high-dimensional encoded features
- healthcare data missingness
- diagnosis code complexity
- threshold sensitivity
- separating utilization from severity


#### Known Limitations

Important limitations:
- observational dataset only
- no causal interpretation
- no distinction between planned/unplanned readmissions
- limited socioeconomic context
- possible hospital-level variation
- missingness may carry hidden signal
- no longitudinal patient timeline

### Step 8.3 - Utilization analysis (`03_utilization_analysis.sql`)

Analyzed:
- inpatient visits
- emergency visits
- outpatient visits
- medication count
- medication change
- length of stay
- combined utilization comparison

####  Key SQL Finding

> inpatient utilization is the most stable and consistent predictor of readmission risk


#### Current Interpretation

- utilization patterns dominate signal structure
- inpatient history is the strongest variable group
- outpatient usage is weak or inconsistent
- emergency usage is noisy but directionally positive

####  Ongoing Challenge

The core analytical challenge remains:

> separating patient-level severity from healthcare system interaction behavior


### 8.4 - Cohort-Based Risk Segmentation (`04_risk_cohorts.sql`)

####  What changed today

Instead of analyzing variables independently, I started grouping patients into risk cohorts.

#### Cohorts tested:
- inpatient utilization tiers
- combined inpatient + medication burden
- inpatient + length-of-stay interactions

#### Key Findings

- inpatient history remains dominant even in combined models
- interaction features provide limited additional separation
- risk is largely driven by utilization frequency, not feature combinations

### 8.5 - Feature Engineering (`05_feature_engineering.sql`)

This is the final stage added in Day 14 and represents a shift from analysis to structured dataset construction.

#### Approach

Feature engineering was done directly in SQL to ensure:
- reproducibility
- consistency across runs
- alignment with downstream modeling workflows

The goal was not to maximize feature complexity, but to build a clean and interpretable feature layer.

#### Engineered features created

1. Utilization score
A weighted composite feature:

- inpatient visits weighted highest
- emergency visits weighted moderately
- outpatient visits weighted lowest

The purpose is to create a single interpretable signal for overall healthcare utilization intensity.

 2. Binary risk flags

Created simple threshold-based indicators:

- high_inpatient_flag (≥ 3 inpatient visits)
- high_emergency_flag (≥ 2 emergency visits)
- high_medication_flag (≥ 20 medications

3. Utilization risk category

A categorical segmentation feature:

- Low Risk
- Medium Risk
- High Risk

#### Key observation

Even after feature engineering, the same pattern remains consistent:

- inpatient utilization is the strongest predictor
- emergency visits show moderate signal
- outpatient usage is weak
- demographics remain relatively low impact

### 8.6 - SQL Feature Validation & Iteration (`06_dashboard_views.sql`)

This stage was less about adding new features and more about validating whether the feature engineering layer is actually stable and meaningful.

After building the initial SQL feature table (`patient_features`) in Day 14, Day 15 focused on re-running, checking, and stress-testing those transformations.

#### What I did

- re-executed full feature table creation in PostgreSQL
- validated aggregation logic for utilization variables
- checked consistency between SQL outputs and Python-side summaries
- reviewed risk flag thresholds
- examined feature correlations and redundancy patterns

#### Key validation checks

1. Utilization score consistency

The weighted utilization score remained stable across runs.

Key structure held:
- inpatient visits = dominant weight
- emergency visits = moderate weight
- outpatient visits = minimal contribution

No structural drift observed.


2. Risk flag behavior

Binary flags behaved as expected:
- high_inpatient_flag strongly aligned with high risk category
- long_stay_flag showed weaker but consistent alignment
- high_emergency_flag introduced some noise but remained directionally useful


3. Redundancy in engineered features

A key realization during this stage:

Most engineered features are not independent signals.

Instead, they are different transformations of the same underlying concept:
> healthcare utilization intensity

Examples:
- utilization_score
- inpatient count
- risk category
- binary inpatient flag

All strongly correlated.

#### Current interpretation shift

At this stage, my understanding is becoming more constrained but clearer:

> most predictive power in this dataset comes from a single underlying dimension: prior healthcare utilization, especially inpatient history

Everything else:
- demographics
- labs
- medications
- admission details

appears to add smaller incremental variation on top of that structure.

---

### 8.7 - Patient Risk Reporting Layer (`07_patient_risk_summary.sql`) & Power BI Dashboard Development

After completing the SQL feature engineering, validation layers and reporting layer, I moved into dashboard development using Power BI.

The objective was to convert the analytical findings into a reporting structure that could support stakeholder decision-making.

#### Reporting dataset creation

A patient-level reporting table was created:

`patient_risk_summary`

The purpose of this table was to aggregate encounter-level activity into patient-level metrics suitable for dashboard consumption.

The table combines:

- utilization measures
- encounter history
- risk category information
- medication burden
- length of stay
- readmission outcomes

This reduced the complexity of reporting directly from encounter-level records while improving dashboard performance.


#### Dashboard design approach

Rather than organizing pages around dataset tables, I organized them around business questions.

The dashboard was structured into four views:

##### Page 1 - Executive Clinical Overview

Answers:

> What is the overall state of the patient population?

Key KPIs:

- total patients
- high risk patients
- readmission rate
- average length of stay
- average medication burden


##### Page 2 - Patient Risk Stratification

Answers:

> How do patient segments differ from one another?

Focus:

- utilization intensity
- medication burden
- patient distribution
- risk concentration


##### Page 3 - Clinical Risk Drivers

Answers:

> What characteristics appear most associated with elevated readmission risk?

Focus:

- utilization score
- inpatient visit frequency
- medication burden
- readmission rate


##### Page 4 - Executive Summary

Answers:

> What are the major findings and recommended actions?

Focus:

- KPI consolidation
- key findings
- stakeholder-oriented recommendations

#### DAX Measures Created

Several reporting measures were developed including:

- Total Patients
- High Risk Patients
- 30-Day Readmission Rate
- Average Length of Stay
- Average Medications per Patient
- Average Inpatient Visits

These measures were designed to remain responsive to dashboard filtering and risk-category segmentation.

#### Dashboard Development Challenges

Several issues emerged during development:

- SQL aggregation mismatches
- missing columns during Power BI refreshes
- table dependency errors
- patient-level vs encounter-level calculation differences
- filter responsiveness of KPI measures

Resolving these issues required several iterations of both SQL table design and Power BI measure logic.

#### Outcome

The final dashboard provides an end-to-end reporting layer connecting:

- Python analysis
- SQL feature engineering
- risk scoring
- business intelligence reporting

This stage transformed the project from a modeling exercise into a more complete healthcare analytics workflow.


---

## Step 9 - Dashboard development (planned)

Eventually I plan to build a dashboard in either Power BI or Tableau Public.

The goal is to simulate something closer to what a healthcare analytics team might actually use, such as:
- readmission monitoring
- patient utilization trends
- high-level KPI tracking

This will likely come after the SQL layer is more developed.

---

## Known Issues

- High class imbalance (~11% positive class)  
- Very high dimensional feature space  
- Some variables with high missingness  
- Diagnosis encoding may need revisiting  

---

## Known limitations

There are a few limitations in the dataset that I’m aware of from early on:

- readmission is only categorical, not exact timing
- a lot of missing data in clinically important variables
- possible differences in coding practices across hospitals
- limited context around patient history outside the dataset
- no time-based structure in dataset
- no separation of planned vs unplanned readmissions
- potential hospital-level bias
- limited socioeconomic context
- observational data only (no causality)

Because of this, I’m treating results as exploratory and descriptive, not causal.

---

## Closing notes 

This methodology documents the complete analytical workflow used in the project, from raw data exploration through to modeling and dashboard development.

Rather than optimizing for model complexity alone, the emphasis was on validating whether consistent, interpretable signals, particularly utilization-based patterns, persisted across statistical analysis, machine learning models, SQL transformations, and BI reporting.