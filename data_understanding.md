# Data Understanding

# Day 1 - Early Exploration Notes

This file captures my initial understanding of the dataset during the first phase of the project. It’s a bit unpolished on purpose, I wrote it while actually exploring the data, so it reflects real observations, questions, and a few things I had to go back and rethink.

Dataset: [Diabetes 130-US hospitals (1999–2008)](https://www.kaggle.com/datasets/brandao/diabetes)

---

## First impressions

This dataset feels pretty “real-world” in the messy sense. It’s not clean or neatly structured like a tutorial dataset, which honestly made the first pass a bit slower than expected.

There are over 100,000 hospital encounters and a mix of demographic, clinical, and administrative variables. A lot of the columns are encoded, and at first glance it’s not always obvious what everything means without checking documentation.

One thing I noticed early: you can’t really jump straight into analysis here,  you have to spend time just understanding what each variable is actually representing.

---

## Missing data (this stood out immediately)

Missing values were one of the first things I had to deal with. The dataset uses “?” instead of proper nulls, which meant I had to clean that before anything else.

Once I did that, the missingness became more obvious and honestly more significant than I expected.

Some columns are heavily incomplete:

- `weight` is almost entirely missing (basically unusable as-is)
- `max_glu_serum` is missing in most rows
- `A1Cresult` also has very high missingness
- `medical_specialty` and `payer_code` are partially missing as well

What I found interesting here is that the missingness doesn’t feel random. It might actually reflect how different hospitals collect or prioritize certain data.

That’s something I want to keep in mind rather than just treating it as “bad data.”

---

## Readmission rate (target variable)

The original dataset has three categories for readmission:

- `<30`
- `>30`
- `NO`

For this project, I simplified it into a binary variable:

- 1 = readmitted within 30 days
- 0 = not readmitted within 30 days

The overall rate of 30-day readmission is around 11%, which immediately signals a class imbalance issue. Not extreme, but definitely something I’ll need to account for later if I move into modeling.

---

## Early patterns I noticed

At a very high level, a few trends started showing up during basic grouping and comparisons:

Patients with prior inpatient visits tend to have higher readmission rates. This was probably the clearest early signal.

Emergency visits show a similar pattern, but slightly weaker.

Length of stay is also a bit higher for readmitted patients, though the difference isn’t dramatic.

Medication count seems slightly higher as well, which could be related to overall patient complexity.

Nothing here is definitive yet, but there are consistent small differences across several variables, which is interesting.

---

## Demographic observations

Gender doesn’t seem to have a strong effect on readmission rates at this stage.

Race also doesn’t show any obvious separation.

Age is a bit more interesting. Most groups behave as expected, but the 20–30 age group stands out with a higher readmission rate than I initially expected.

I’m not fully sure what’s driving that yet. It could be:
- smaller sample size in that group
- specific clinical subpopulations
- or something related to pregnancy/gestational diabetes cases

I don’t want to over-interpret it yet, so I’ve just flagged it for deeper investigation later.

---

## Diagnosis variables (still messy)

The diagnosis columns (`diag_1`, `diag_2`, `diag_3`) are probably one of the most complex parts of the dataset.

They use ICD-9 codes, and there are a lot of unique values. At this stage, they’re not very usable in raw form.

There are also inconsistencies and missing values scattered across these fields.

Right now, I think they will need to be grouped into broader categories before they can be useful for analysis or modeling. I haven’t decided exactly how yet — that’s still open.

---

## Things I’m still thinking about

A few open questions I have after this first pass:

- Are lab test variables useful enough to keep despite missingness?
- How should I handle high-cardinality diagnosis codes without oversimplifying them too much?
- Does payer_code actually contribute meaningful signal or is it mostly noise?
- How much of what I’m seeing is patient-level risk vs hospital/system-level variation?

I don’t have clear answers yet, but I think these will become clearer after deeper analysis.

---

## General reflection

Overall, this feels less like a “clean dataset analysis” and more like trying to understand a real hospital data system, which is more complicated than expected.

A lot of the early work has been less about drawing conclusions and more about figuring out what the data actually represents, where it’s incomplete, and what assumptions I can safely make.

That part has probably been the most important so far.

---

# Progress Updates

# Day 2 - Feature Engineering + Data Structuring

## What I worked on today

- Built full feature engineering pipeline
- Removed identifier columns (encounter_id, patient_nbr)
- Dropped low-information features
- Handled categorical variables using one-hot encoding
- Created final ML-ready dataset (~2418 features)
- Separated target variable to avoid leakage

---

## Key insights from today

- Feature space expanded significantly due to high-cardinality variables (especially diagnosis codes)
- Dataset is highly imbalanced (~11% positive class)
- Encoding strategy increased complexity more than expected
- Tradeoff became clear between simplicity vs dimensionality

---

## Updated understanding of the problem

At this stage, the project has shifted from simple EDA into feature engineering and modeling preparation.

The main challenge now is not just understanding the data, but deciding:
- how to represent high-cardinality clinical variables
- how to manage class imbalance
- how to prevent overfitting in a very wide feature space

---

## What changed in my thinking since Day 1

Originally, I thought this project would move quickly from EDA to modeling.

But after working with the data more deeply, I realized:
- most of the effort is actually in data preparation
- clinical datasets are messy and heavily encoded
- feature engineering decisions will strongly affect model outcomes

---

## Next step

Move into statistical analysis to validate early patterns before modeling.

---

# Day 3 - Statistical Validation of Early Patterns

## What I worked on today

Today I moved from exploration into statistical validation to check whether the patterns I observed during EDA were actually supported by data.

I focused on:
- Performing hypothesis testing on key variables
- Using chi-square tests for categorical variables
- Using t-tests for numerical variables
- Comparing readmitted vs non-readmitted patient groups

The goal here was not to build anything predictive yet, but to validate whether earlier observations were statistically meaningful or just visual patterns.

---

## Key confirmations from statistical testing

A few patterns became clearer after running formal tests:

- Prior inpatient visits showed the strongest and most consistent relationship with 30-day readmission
- Emergency visits and number of medications also showed statistically significant differences between groups
- Length of stay was statistically significant, but the actual difference between groups was relatively small
- Demographic variables such as race and gender did not show strong or consistent relationships with readmission

Overall, the results mostly confirmed what I suspected during EDA, but with clearer separation in some variables than others.

---

## Important observation: statistical vs practical significance

One thing that stood out during this stage is how easily large datasets can produce very small p-values.

With ~100,000 records, even small differences between groups can become statistically significant.

Because of this, I started to think more carefully about:
- Whether a relationship is statistically significant
- Versus whether it is practically meaningful in a healthcare context

This distinction feels especially important in this dataset.

---

## Reflections

A few things surprised me during this phase:

- I initially expected emergency visits to be one of the strongest indicators, but inpatient history turned out to be more influential
- Some demographic variables I thought might matter ended up showing very weak relationships
- A lot of the signal in this dataset seems to come from prior healthcare utilization rather than demographic or static patient attributes

It also made me question whether I am observing true clinical risk factors or more general healthcare system usage patterns.

That distinction is not fully clear yet, but it feels important.

---

## Limitations

A few limitations to keep in mind:

- Multiple hypothesis testing was not adjusted for, which may inflate false positives
- Tests do not account for confounding variables (e.g., severity vs access to care)
- Readmission is influenced by both patient-level and system-level factors, which are not separated in this dataset

These limitations mean results should be interpreted as exploratory rather than causal.

---

## Next step

Next, I will move into modeling to see whether these statistically significant patterns actually translate into predictive power.

I will start with a baseline model (likely logistic regression) and evaluate performance using appropriate metrics for imbalanced data.

---

---

# Day 4 — Baseline Modeling (Logistic Regression)

## What I built

I trained a baseline Logistic Regression model using:
- stratified train/test split
- standardized numerical features
- balanced class weights

Evaluation focused on:
- recall
- precision
- ROC-AUC

instead of raw accuracy due to class imbalance.

---

## Baseline results

### ROC-AUC:
~0.64

### Key metrics:
- recall for readmitted patients: ~0.55
- precision: ~0.17

The model captures signal, but performance is still limited.

A lot of false positives remain.

---

## Most important modeling observation

The most interesting part was not actually model performance.

The important part was:
the model reinforced the same utilization-related patterns observed earlier.

Variables tied to:
- inpatient history
- medication intensity
- healthcare interaction

continued appearing important.

That consistency across:
- EDA
- statistical testing
- modeling

made the pattern feel more credible.

---

## Shift in interpretation

At this point, my interpretation became less patient-only focused.

Instead of thinking:
readmission simply reflects sickness

I started thinking:
readmission may partially reflect repeated healthcare system interaction patterns.

In other words:
patients deeply connected to the healthcare system appear substantially more likely to cycle back into readmission.

That does NOT prove causation.

But it consistently appears throughout the project so far.

---

## Current working hypothesis

Current working idea:

> healthcare utilization history may be more predictive of readmission than static demographic characteristics.

That became the central narrative emerging from the project.

---

## What I still want to test

The next important step is checking whether:
- tree-based models
- feature importance rankings
- more flexible algorithms

continue reinforcing this same utilization-driven story.

If they do, that strengthens the interpretation considerably.

---

## Overall Reflection So Far

This project has gradually become more about:
> understanding what hospital readmissions actually represent in healthcare data.

That shift ended up being much more interesting than I expected going in.

# Day 5 – After Initial Modeling Reflections

After building both Logistic Regression and Random Forest models, my understanding of the dataset shifted slightly.

One thing that stood out is that even though Random Forest is a more flexible model, it did not improve the identification of readmitted patients. In fact, it performed significantly worse on recall for the minority class.

This made me rethink my earlier assumption that more complex models would naturally capture the patterns better.

It also reinforced something I had been seeing since EDA:

utilization-related variables (especially inpatient history) consistently carry signal across every stage of the analysis.

However, the modeling results also highlighted a limitation:
even when signal exists, separating high-risk patients is not straightforward in this dataset.

At this point, I’m starting to think that readmission risk is not just a patient-level prediction problem, but also reflects system-level interaction patterns and class imbalance effects that standard models struggle with.

---

# Day 6 - Threshold Tuning + Model Interpretation

## What changed today

Instead of immediately abandoning the Random Forest model, I experimented with threshold tuning.

I lowered the classification threshold:
- from 0.50
- to 0.30

---

## Outcome

- Recall improved modestly
- Precision decreased
- More high-risk patients were identified

The improvement itself was not huge.

But the important part was understanding:
- why the tradeoff happened
- and how healthcare priorities affect model evaluation

---

# Biggest realization so far

At this point, the project stopped feeling like:
> “which model gets the best score?”

and started feeling more like:
> “what kind of mistakes matter most in healthcare prediction?”

That distinction changed how I interpreted everything afterward.

A false negative:
- missing a potentially high-risk patient

may matter much more clinically than:
- generating additional false positives

That perspective made threshold tuning feel much more meaningful than just another modeling trick.

---

# Current understanding of the dataset

Right now, my working interpretation is:

readmission risk in this dataset appears heavily connected to patterns of healthcare utilization and repeated system interaction.

That does NOT mean utilization causes readmission.

But it consistently appears to carry predictive signal more strongly than many demographic variables.

I still want to test whether that pattern holds under:
- stronger models
- feature importance analysis
- and future validation work.

---

# Questions I still have

- Are utilization variables partially acting as severity proxies?
- How much hospital-level variation exists?
- Would grouped diagnosis categories improve performance?
- Is missingness itself predictive?

---

# Day 7 - Modeling Expansion (XGBoost + Evaluation Deepening)

## What I worked on today

Today I added a third model into the mix: XGBoost.

This was less about “just trying another algorithm” and more about seeing whether a stronger boosting model actually changes the story I’ve been seeing so far, or if it just confirms the same pattern with slightly better scores.

Up to now I’ve mostly been comparing models in a pretty standard way (ROC-AUC, recall, precision). Today felt like a small shift in how I was looking at things, more focus on what the model is actually doing with the minority class, not just overall performance.

---

## What changed today (this felt important)

The shift today was basically this:

- before: “which model performs best overall?”
- now: “which model is actually useful for identifying readmitted patients?”

That second question sounds simple, but it changes how you read every metric.

Especially in this dataset.

---

## XGBoost modeling work

I trained an XGBoost classifier on the full engineered dataset (~2418 features), and compared it directly against Logistic Regression and Random Forest.

Main steps:

- trained XGBoost using the same train/test split as earlier models (kept things consistent on purpose)
- handled a few feature alignment issues from one-hot encoding (this took longer than expected)
- evaluated using:
  - ROC-AUC
  - precision
  - recall
  - confusion matrix
- compared outputs side-by-side with previous models

Nothing too exotic here, but I wanted a fair comparison rather than tuning XGBoost in isolation.

---

## Key results (high-level)

- XGBoost gave the best ROC-AUC so far (~0.69-ish)
- recall for the minority class is still… honestly quite low
- predictions are still heavily skewed toward the majority class
- performance changes more with threshold than with model choice itself

So in a way, the “best model wins” idea is not really holding up here.

---

## Important observation: model comparison is not enough

One thing that became clearer today is that ROC-AUC alone is not telling the full story.

Even though XGBoost ranks patients better overall, it still doesn’t reliably surface readmitted patients unless I start adjusting thresholds.

So there’s this gap:

- ROC-AUC → “model ranks risk reasonably well”
- but reality → “still misses a lot of actual positives”

That gap feels important in a healthcare context.

---

## Feature behavior (consistency check)

What stood out again (and this is becoming a pattern now) is that the same feature groups keep showing up everywhere:

- `number_inpatient`
- `number_emergency`
- medication-related variables (especially insulin changes)
- general utilization intensity features

It doesn’t really matter which model I use, these features stay near the top.

Across:
- EDA
- statistical tests
- Logistic Regression
- Random Forest
- XGBoost

…the story is surprisingly consistent.

At this point, it’s hard to ignore that.

---

## Current interpretation update

My current (still evolving) interpretation is:

> readmission risk in this dataset seems strongly tied to prior healthcare utilization patterns, but actual patient-level prediction is still constrained by imbalance and overlapping signals.

Not saying this is causal, it’s just what keeps showing up no matter what method I use.

---

## Challenges I’m noticing more clearly now

A few things are becoming harder to ignore:

- class imbalance is basically steering most model behavior
- feature space is still very high-dimensional (and kind of messy to interpret)
- model improvements are incremental, not dramatic
- thresholds matter almost as much as the model itself

That last point is starting to feel more important than I expected.

---

## What I’m thinking about next

Going forward, I want to:

- move into more structured precision-recall threshold tuning (instead of guessing 0.3 / 0.5 manually)
- test whether XGBoost class weighting / scale_pos_weight changes recall meaningfully
- re-evaluate all models using a consistent decision threshold framework
- start thinking more seriously about what “final model selection” actually means here (because ROC-AUC alone is not enough)

- Can minority-class prediction improve substantially with better models?
