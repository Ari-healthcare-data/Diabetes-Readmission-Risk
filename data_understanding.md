# Data Understanding: Early Exploration Notes

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