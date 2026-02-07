# Driving Repeat Revenue Through Customer Lifecycle Analytics

## Overview

This project analyzes **repeat revenue drivers** using customer-level transaction data from an online retail business.
It applies **Cohort Analysis, Pareto (80/20) Revenue Analysis, RFM Segmentation, and Time-Series Forecasting** to understand how customer behavior evolves across the lifecycle and how revenue concentration and retention impact growth.

The work is designed from a **business analytics and decision-intelligence perspective**, with SQL-first transformations and analytics that mirror real-world BI and growth analytics workflows.

---

## Business Objectives

* Identify **repeat purchase behavior** and customer retention patterns
* Quantify **revenue concentration** (top customers vs long tail)
* Segment customers using **RFM (Recency, Frequency, Monetary)**
* Analyze **second-purchase funnel drop-offs**
* Create **forecast-ready revenue time series** for planning and growth projections
* Enable lifecycle-driven marketing and retention strategies

---

## Dataset

* **Source:** Online Retail transactional dataset
* **Granularity:** Invoice-level customer transactions
* **Key fields:**

  * Customer ID
  * Invoice date
  * Order value
  * Country (UK-focused analysis for consistency)

```
dataset/
└── Online Retail Final/
    └── online_retail_final.csv
```

---

## Repository Structure

```
Detailed Marketing- Cohort, Pareto, RFM, Forecast/
│
├── README.md
│
├── detailed-marketing-cohort-pareto-rfm-forecast/
│   │
│   ├── dataset/
│   │   └── Online Retail Final/
│   │       └── online_retail_final.csv
│   │
│   ├── notebook2/
│   │   ├── README.md
│   │   ├── report.md
│   │   │
│   │   └── sql/
│   │       ├── Online Retail Staging.sql
│   │       ├── Online Retail Table.sql
│   │       ├── Standardize Column Names.sql
│   │       ├── Indexes for online_retail_final.sql
│   │       │
│   │       ├── Monthly Customer Cohort.sql
│   │       ├── Cohort Revenue & Customer Count.sql
│   │       │
│   │       ├── Pareto 80-20 Revenue.sql
│   │       │
│   │       ├── Second-Purchase Funnel.sql
│   │       ├── UK RFM Customers Map.sql
│   │       │
│   │       ├── UK Daily and Weekly Revenue.sql
│   │       ├── UK Monthly Revenue.sql
│   │       └── Forecast-Ready Daily Revenue Series.sql
```

---

## Analytical Components

### 1. Data Preparation & Modeling

* Column standardization (snake_case)
* Staging and final analytical tables
* Indexing for analytical performance
* UK-specific filtered views for consistency

**Key SQL files**

* `Standardize Column Names.sql`
* `Online Retail Staging.sql`
* `Online Retail Table.sql`
* `Indexes for online_retail_final.sql`

---

### 2. Cohort Analysis (Customer Lifecycle)

* Monthly customer cohorts based on **first purchase month**
* Customer retention and revenue contribution over time
* Cohort-level customer counts and revenue tracking

**Key outputs**

* Retention curves
* Revenue-weighted cohort performance

**Key SQL files**

* `Monthly Customer Cohort.sql`
* `Cohort Revenue & Customer Count.sql`

---

### 3. Pareto (80/20) Revenue Analysis

* Measures revenue concentration across customers
* Identifies top revenue-generating customer segments
* Supports prioritization of retention and loyalty strategies

**Key SQL file**

* `Pareto 80-20 Revenue.sql`

---

### 4. Second-Purchase Funnel Analysis

* Tracks conversion from first purchase → second purchase
* Identifies early churn points in the customer lifecycle
* Highlights critical window for retention marketing

**Key SQL file**

* `Second-Purchase Funnel.sql`

---

### 5. RFM Segmentation

* Customers scored on:

  * **Recency** (how recently they purchased)
  * **Frequency** (how often they purchase)
  * **Monetary** (how much they spend)
* Creation of actionable segments:

  * Champions
  * Loyal customers
  * At-risk customers
  * Dormant customers

**Key SQL file**

* `UK RFM Customers Map.sql`

---

### 6. Revenue Time Series & Forecast Readiness

* Daily, weekly, and monthly revenue aggregation
* Clean, gap-free time series suitable for forecasting models
* Supports downstream ARIMA / Prophet / ML forecasting

**Key SQL files**

* `UK Daily and Weekly Revenue.sql`
* `UK Monthly Revenue.sql`
* `Forecast-Ready Daily Revenue Series.sql`

---

## Reporting & Documentation

```
notebook2/
├── README.md     → Analysis workflow explanation
└── report.md     → Business insights, findings, and conclusions
```

The final report focuses on:

* Revenue concentration risks
* Retention leverage points
* Lifecycle-based marketing recommendations
* Forecasting implications for planning

---

## Tools & Skills Demonstrated

* **SQL (advanced analytics queries)**
* **Cohort & retention modeling**
* **RFM segmentation**
* **Pareto analysis**
* **Time-series preparation**
* **Business-driven analytics design**
* **Marketing & lifecycle analytics**

---

## Use Cases

* Retention and loyalty strategy design
* Revenue risk analysis
* Lifecycle-driven marketing campaigns
* Growth forecasting and planning
* Executive-level performance reporting

---

## Next Extensions (Optional)

* Forecasting model implementation (ARIMA / Prophet)
* Dashboarding (Power BI / Tableau)
* Campaign simulation by RFM segment
* CLV modeling


