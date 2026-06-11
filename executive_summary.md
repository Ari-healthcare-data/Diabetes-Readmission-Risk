# Executive Summary  
## Diabetes Hospital Readmission Prediction, Risk Stratification & Utilization Analysis
**Diabetes 130-US Hospitals (1999–2008)**  

**Prepared by:** Ari M.

---

# 1. Context

Hospital readmissions are both a clinical outcome signal and an operational capacity constraint, reflecting how effectively health systems manage chronic disease, discharge transitions, and post-acute care continuity.

This project analyzes 30-day diabetes-related readmissions using the Diabetes 130-US Hospitals dataset (~71.5K unique patients, ~101K encounters).

Across exploratory analysis, statistical testing, machine learning models, SQL feature engineering, and BI validation, a consistent pattern emerged:

> Prior healthcare utilization is a stronger predictor of readmission risk than static demographic or isolated clinical attributes.

This reframed the problem from prediction to:

> Patient-level risk stratification for operational prioritization under constrained care management resources

The workflow integrates:
- EDA and statistical hypothesis testing  
- Machine learning models (Logistic Regression, Random Forest, XGBoost)  
- SQL-based feature engineering and cohort aggregation  
- Power BI dashboards for operational interpretation  

---

# 2. System Snapshot

## Executive Metrics

![Executive Clinical Overview]( images/page_1_overview.png)

| Metric | Value |
|--------|------|
| Total Patients | 71.52K |
| 30-Day Readmission Rate | 7.11% |
| Avg Length of Stay | 4.30 days |
| Avg Medications | 15.79 |
| Avg Utilization Score | 2.17 |
| High-Risk Patients | 3.50K (~5%) |

## Risk Segmentation

| Segment | Patients | Share |
|----------|----------|-------|
| Low Risk | 68.01K | 95.1% |
| Intermittent High Risk | 2.20K | 3.1% |
| Chronic High Risk | 1.30K | 1.8% |

~5% of patients account for a disproportionate share of utilization intensity and downstream readmission burden.

---

# 3. Key Findings

## 3.1 Prior utilization is the primary risk driver

![Clinical Risk Drivers]( images/page_3_clinical_risk_drivers.png)

Utilization intensity is the most stable predictor across all methods (EDA → statistical testing → ML → SQL validation).

| Metric | Chronic High Risk | Intermittent High Risk | Low Risk |
|--------|----------|----------|----------|
| Utilization Score | 12.11 | 9.81 | 1.09 |
| Inpatient Visits | 2.75 | 2.10 | 0.23 |

High-risk cohorts are defined primarily by repeated system interaction rather than demographic or static clinical attributes.

---

## 3.2 Readmission reflects system interaction patterns

High-risk cohorts are characterized by:

- repeated inpatient utilization  
- fragmented continuity of care  
- high treatment complexity  
- recurrent post-discharge system engagement  

This indicates the model is identifying care pathway intensity, not isolated clinical events.

---

## 3.3 Risk segmentation is directionally valid

| Segment | Readmission Rate |
|----------|------------------|
| Low Risk | 6.19% |
| Intermittent High Risk | 22.38% |
| Chronic High Risk | 29.33% |

The consistent increase in readmission rates across risk tiers suggests the segmentation is practical for prioritizing follow-up and care-management interventions.

---

## 3.4 Medication burden scales with complexity

| Segment | Avg Medications |
|----------|----------------|
| Low Risk | 15.71 |
| Intermittent High | 17.01 |
| Chronic High Risk | 17.57 |

Average medication burden increases with risk but appears to function primarily as a complexity proxy rather than a causal driver.

---

## 3.5 Feature engineering > model complexity

Model performance:

- Logistic Regression: baseline signal capture  
- Random Forest: marginal nonlinear gain  
- XGBoost: best ranking performance (~0.69 ROC-AUC)

However, differences between models were secondary to utilization-driven feature engineering and class imbalance structure.

---

# 4. Interpretation 

The framework does not simply predict readmission; it identifies patients embedded in high-utilization care pathways that historically correlate with readmission events.

![Patient Risk Stratification]( images/page_2_patient_risk_stratification.png)

This reframes outputs from prediction to care intervention prioritization.

Operational relevance:
- discharge planning prioritization  
- case management allocation
- post-discharge outreach follow-up
- care coordination interventions

The output is therefore best interpreted as a resource allocation signal under capacity constraints, rather than a binary prediction system. 

---

# 5. Executive View of Utilization Burden

![Executive Summary]( images/page_4_executive_summary.png)

Key structural insight:

- ~5% of patients drive disproportionate utilization and readmission risk  
- risk clusters are stable and utilization-driven  
- segmentation is interpretable for operational deployment  

---

# 6. Limitations

### Data Constraints
- Encounter-level structure inflates repeat-patient signal  
- Utilization variables inherently encode healthcare access patterns  

### Modeling Constraints
- No temporal progression modeling  
- No separation of planned vs unplanned readmissions  
- Potential confounding between severity and system exposure  

### Generalizability
- No external validation beyond dataset boundaries  

---

# 7. Practical Implications

## 7.1 Care management prioritization
Supports targeted allocation of limited resources toward highest-risk cohorts for:

- post-discharge planning and outreach
- case management triage
- schedule post-discharge follow-up

## 7.2 Discharge workflow optimization
Supports earlier and more structured intervention for high-risk patients through:

- medication reconciliation prioritization
- transitional care coordination
- early follow-up planning

## 7.3 Operational planning lens
Dashboards provide a consolidated view of:

- risk distribution
- utilization concentration
- readmission burden segmentation

Supporting executive-level monitoring of care intensity distribution.

## 7.4 Key tradeoff: coverage vs capacity

Threshold selection directly governs operational load:

- Lower thresholds: higher recall, increased workload
- Higher thresholds: focused intervention, higher miss risk

This introduces a direct capacity allocation tradeoff, making threshold selection a resource decision, not a modeling choice.

---

# 8. Conclusion

This work evolves from a predictive modeling exercise into a healthcare operations decision-support framework.

Across all analytical layers, one signal remains consistent:

> Prior healthcare utilization is the most stable and dominant indicator of 30-day readmission risk.

In practical terms, the analysis suggests that readmission risk is less about isolated clinical events and more about recurring patterns of healthcare utilization.

More importantly, the framework translates this signal into actionable patient segmentation by:

- identifying high-utilization patient cohorts
- surfacing patterns associated with repeated hospital use
- supporting targeted allocation of limited care-management resources

By translating those patterns into interpretable risk cohorts, the framework provides a practical mechanism for prioritizing discharge planning, care coordination, and follow-up resources toward the relatively small group of patients most likely to generate future utilization and readmission burden.
