# 🏥 Healthcare Operations Analytics Dashboard

<div align="center">

![Python](https://img.shields.io/badge/Python-3.10+-blue?style=flat-square&logo=python)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?style=flat-square&logo=powerbi)
![XGBoost](https://img.shields.io/badge/XGBoost-R²%3D0.49-green?style=flat-square)
![CMS Data](https://img.shields.io/badge/CMS-5%2C366%20Hospitals-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)

**End-to-end healthcare analytics pipeline analyzing patient satisfaction, readmission rates, and ER efficiency across 5,366 U.S. hospitals using CMS public data.**

[Key Findings](#-key-findings) • [Dashboard](#-power-bi-dashboard) • [Notebooks](#-notebooks) • [Data Sources](#-data-sources) • [How to Run](#-how-to-run)

</div>

---

## 📊 Project Overview

This project builds a production-grade healthcare analytics pipeline from raw CMS (Centers for Medicare & Medicaid Services) public data. It combines clinical quality metrics, socioeconomic context, and machine learning to generate actionable insights for hospital administrators and healthcare analysts.

| Metric | Value |
|--------|-------|
| Hospitals analyzed | 5,366 |
| States covered | 51 (all US states + DC) |
| Features engineered | 57 |
| Best model R² | 0.49 (XGBoost) |
| R² improvement over baseline | +22.8% |
| Power BI dashboard tabs | 9 |

---

## 🔍 Key Findings

**1. Hospital size is the strongest operational predictor of patient satisfaction**
Bed count showed a significant negative correlation with satisfaction (r=-0.386, p<0.0001) — larger hospitals score 8–10 points lower than small hospitals despite higher clinical ratings.

**2. ER wait time is the #1 modifiable driver of satisfaction**
ER wait time (OP_18b) ranked as the top operational feature in the XGBoost model. Reducing ER wait times has a greater impact on satisfaction than improving clinical metrics.

**3. Poverty rate does not predict satisfaction (null result)**
Contrary to expectations, state poverty rate showed no significant correlation with satisfaction (r=0.013, p=0.35) — suggesting satisfaction scores reflect care delivery quality rather than patient socioeconomic expectations.

**4. Midwest states outperform coastal states by 7+ points**
Nebraska (77.3%), Wisconsin (76.3%), and Kansas (76.2%) lead satisfaction rankings. DC (67.2%) and NJ (68.9%) rank lowest — driven primarily by ER wait time differences, not clinical quality.

**5. ER wait times are worsening despite other improvements**
Time series analysis shows ER wait increased +28 minutes over 12 quarters (2022–2024) while satisfaction, readmission, and mortality all improved — indicating a persistent staffing and capacity crisis.

**6. High-rated hospitals ≠ high satisfaction**
Cluster analysis identified a "High Rated · Slow ER" profile (1,115 hospitals) where 4–5 star CMS ratings coexist with below-average satisfaction — star ratings don't fully capture patient experience.

---

## 🗂️ Project Structure

```
Healthcare-Operations-Dashboard/
│
├── notebooks/
│   ├── healthcare_data_cleaning_colab.ipynb      # Data pipeline (Notebook 1)
│   ├── healthcare_advanced_analytics.ipynb        # ML models + clustering (Notebook 2)
│   ├── healthcare_improvements.ipynb              # XGBoost v2 + maps + time series (Notebook 3)
│   └── healthcare_day1_enrichment.ipynb           # Census + POS + RUCC enrichment (Notebook 4)
│
├── data/
│   └── clean/
│       ├── healthcare_master.csv                  # Base master dataset (32 features)
│       ├── healthcare_master_enriched.csv         # Enriched master (57 features)
│       ├── tab1_patient_flow.csv                  # ER wait, admissions
│       ├── tab2_quality_outcomes.csv              # Mortality, complications
│       ├── tab3_patient_satisfaction.csv          # HCAHPS scores
│       ├── tab4_operational_efficiency.csv        # Readmissions, flags
│       ├── tab5_regression_v3.csv                 # Predicted satisfaction scores
│       ├── tab6_clustering_v2.csv                 # Hospital cluster assignments
│       ├── tab8_time_series.csv                   # 12-quarter trend data
│       ├── tab9_geographic_summary.csv            # State-level aggregates
│       └── tab10_enriched_state_summary.csv       # Enriched state summary
│
├── assets/
│   ├── eda_overview.png                           # 4-panel EDA chart
│   ├── regression_v3_enriched.png                 # R² progression chart
│   ├── socioeconomic_insights.png                 # Income/poverty/beds analysis
│   ├── clustering_improved.png                    # Hospital profiles
│   ├── time_series.png                            # 12-quarter trends
│   ├── map_avg_satisfaction.html                  # Interactive satisfaction map
│   ├── map_avg_er_wait.html                       # Interactive ER wait map
│   ├── map_avg_readmission_rate.html              # Interactive readmission map
│   └── map_state_performance_score.html           # Interactive performance map
│
├── requirements.txt
├── .gitignore
└── LICENSE
```

---

## 🤖 Machine Learning

### Regression — Predicting Patient Satisfaction

| Model | R² | RMSE | CV R² |
|-------|-----|------|-------|
| Linear Regression (baseline) | 0.299 | 4.70 | 0.287 |
| Gradient Boosting (v1) | 0.398 | 4.35 | 0.390 |
| XGBoost v2 (feature engineering) | 0.467 | 4.10 | 0.481 |
| **XGBoost v3 (enriched)** | **0.489** | **3.97** | **0.500** |

**Top predictors:** hospital star rating, bed count (log), hospital type, ER wait time, state geographic context

### Clustering — Hospital Operational Profiles (K=4)

| Cluster | Label | Hospitals | Key Characteristic |
|---------|-------|-----------|-------------------|
| C0 | ⭐ High Quality · Efficient | 1,742 | High satisfaction + fast ER |
| C1 | ⚠️ Low Quality · High Risk | 1,115 | Low satisfaction + slow ER |
| C2 | 🏥 High Rated · Slow ER | 1,207 | High CMS rating but slow ER |
| C3 | ✅ Good Satisfaction · Fast ER | 1,302 | Average quality + efficient |

---

## 📈 Power BI Dashboard

9-tab interactive dashboard built in Power BI Desktop:

| Tab | Content |
|-----|---------|
| 1 | Patient Flow — ER wait times, admissions, hospital types |
| 2 | Quality & Outcomes — 30-day mortality, complications |
| 3 | Patient Satisfaction — HCAHPS scores by category |
| 4 | Operational Efficiency — Readmission rates, flags |
| 5 | Predictive Model — Over/underperforming hospitals |
| 6 | Hospital Profiles — Cluster analysis |
| 7 | Cost vs Quality — Spending correlation |
| 8 | Trends Over Time — 12-quarter time series |
| 9 | Geographic View — State-level choropleth maps |

**Slicers:** State · Hospital Type · Performance Tier · Ownership

---

## 📦 Data Sources

| Dataset | Source | Records | Link |
|---------|--------|---------|------|
| Hospital General Information | CMS | 5,366 | [xubh-q36u](https://data.cms.gov/provider-data/dataset/xubh-q36u) |
| Timely & Effective Care | CMS | 5,366 | [yv7e-xc69](https://data.cms.gov/provider-data/dataset/yv7e-xc69) |
| Complications & Deaths | CMS | 5,366 | [ynj2-r877](https://data.cms.gov/provider-data/dataset/ynj2-r877) |
| HCAHPS Patient Survey | CMS | 5,366 | [dgck-syfz](https://data.cms.gov/provider-data/dataset/dgck-syfz) |
| Unplanned Hospital Visits | CMS | 5,366 | [632h-zaca](https://data.cms.gov/provider-data/dataset/632h-zaca) |
| ACS 5-Year Estimates | Census Bureau | 51 states | [2023 ACS](https://api.census.gov/data/2023/acs/acs5) |
| Provider of Services | CMS | 44,429 | [POS File](https://data.cms.gov/provider-characteristics/hospitals-and-other-facilities) |
| Rural-Urban Continuum Codes | USDA ERS | 51 states | [RUCC 2023](https://www.ers.usda.gov/data-products/rural-urban-continuum-codes/) |

> **Note:** Raw CMS files are excluded from this repo due to size. Download from the links above and place in `data/raw/`.

---

## 🚀 How to Run

### Prerequisites
```bash
pip install -r requirements.txt
```

### Option 1 — Google Colab (Recommended)
1. Open any notebook in `notebooks/` via Google Colab
2. Run all cells top-to-bottom
3. Download the 5 CMS datasets manually and upload when prompted
4. Clean CSVs are saved to Google Drive automatically

### Option 2 — Local
```bash
git clone https://github.com/Aditya768/Healthcare-Operations-Dashboard.git
cd Healthcare-Operations-Dashboard
pip install -r requirements.txt
jupyter notebook notebooks/healthcare_data_cleaning_colab.ipynb
```

### Notebook Execution Order
```
1. healthcare_data_cleaning_colab.ipynb      # Run first — generates master CSV
2. healthcare_advanced_analytics.ipynb        # Run second — ML models
3. healthcare_improvements.ipynb              # Run third — improved models + maps
4. healthcare_day1_enrichment.ipynb           # Run fourth — data enrichment
```

---

## 📐 Methodology

- **Missing data:** Median imputation for numeric, mode for categorical (MAR assumption, Little & Rubin 2002)
- **Outliers:** IQR winsorization at 1.5×IQR (Tukey 1977)
- **Readmission threshold:** National median READM_30_HOSP (CMS HRRP, ACA Section 3025)
- **ER threshold:** 300 minutes (IOM 2006 benchmark)
- **HCAHPS reliability:** Cronbach's α > 0.70 (Nunnally 1978)
- **Model validation:** 5-fold cross-validation, 80/20 train-test split

---

## 📋 Data Citation

Centers for Medicare & Medicaid Services. (2024). *Hospital Compare datasets* [Data files]. U.S. Department of Health & Human Services. https://data.cms.gov/provider-data/

U.S. Census Bureau. (2023). *American Community Survey 5-Year Estimates* [Data files]. https://api.census.gov/data/2023/acs/acs5

USDA Economic Research Service. (2023). *Rural-Urban Continuum Codes* [Data files]. https://www.ers.usda.gov/data-products/rural-urban-continuum-codes/

---

## 📝 Resume Bullets

```
• Built end-to-end healthcare analytics pipeline (Python, XGBoost, Power BI) analyzing
  5,366 US hospitals using CMS public data; engineered 57 features across 4 external
  datasets (CMS, Census ACS 2023, USDA RUCC, CMS POS)

• Developed XGBoost model predicting patient satisfaction (R²=0.49, +22.8% over baseline)
  with feature engineering; identified hospital bed count and ER wait time as top predictors

• Applied K-means clustering (K=4) to segment hospitals into operational profiles,
  enabling peer-group benchmarking across satisfaction, readmission, and mortality metrics

• Built 9-tab Power BI dashboard with geographic choropleth maps, time series trends,
  predictive analytics, and hospital cluster profiles; added slicers for state/type/tier
```

---

## 👤 Author

**Aditya** · M.S. Applied Data Science · Syracuse University iSchool · 2026

[![Portfolio](https://img.shields.io/badge/Portfolio-aditya768.github.io-blue?style=flat-square)](https://aditya768.github.io/Portfolio/)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat-square&logo=linkedin)](https://linkedin.com/in/your-profile)
