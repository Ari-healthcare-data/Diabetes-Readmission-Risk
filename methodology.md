# Methodology (Work in Progress)

This document outlines how I approached the project so far. It’s still evolving, and I expect it to change quite a bit as I move deeper into the analysis and eventually into modeling and dashboard work.

Right now it mostly reflects what I’ve actually done and how I’ve been thinking through the dataset step by step, rather than a strict or fully finalized methodology.

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

## Step 5: Feature Engineering

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

## Why this mattered

The default threshold was heavily favoring the majority class.

Lowering the threshold increased sensitivity toward the minority class.

### Result
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

---

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


---

## Step 8 - Thinking ahead to SQL layer

I haven’t built the SQL part yet, but I’m planning to use PostgreSQL to simulate more of a hospital reporting environment.

The idea is to eventually build queries around things like:
- readmission rates by patient group
- utilization summaries
- hospital-level aggregations

Right now this is still in the planning stage.

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

## Closing notes (for now)

This methodology will continue to evolve as the project progresses.

At this stage, the focus is less on building a perfect pipeline and more on understanding the data deeply before modeling.
