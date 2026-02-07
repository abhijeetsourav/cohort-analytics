# Executive Summary Build Log (Live)

## STEP 0 — Data, Time-Series & Customer Foundations (Prior Analysis)

This step consolidates all **pre-existing analysis completed before the deep-dive retention and revenue work**, and establishes the analytical foundation used by all subsequent steps.

---

### STEP 0.1 — UK Revenue Time-Series Construction (Daily)

**Business Question**
How does daily revenue behave in the UK market, and is the dataset reliable for trend and seasonality analysis?

**What was done**

* Filtered transactions to `country = 'United Kingdom'`
* Explicitly normalized mixed `invoice_date` string formats into timestamps
* Aggregated line-item transactions into **daily revenue**

**Validated Results**

* Days covered: **374 calendar days**
* Date range: **2010-12-01 → 2011-12-09**
* Zero-revenue days: **69 days (~18%)**

**Business Interpretation**

* Confirms a full operational year of UK activity
* Zero-revenue days likely correspond to **weekends, holidays, or planned non-operational periods**
* Daily series is complete, continuous, and suitable for forecasting and seasonality modeling

**Decision Enabled**

* Revenue data is **forecast-ready** and can support weekly and annual seasonality analysis

---

### STEP 0.2 — Weekly Revenue Aggregation (Executive View)

**Business Question**
How does revenue perform when smoothed to an executive-friendly weekly view?

**What was done**

* Aggregated validated daily revenue into weekly buckets
* Materialized weekly revenue as a reusable analytics asset

**Validated Results**

* Weeks covered: **53**
* Date range: **2010-11-29 → 2011-12-05**

**Business Interpretation**

* Dataset spans a complete commercial year
* Weekly aggregation removes daily noise and exposes demand cycles
* Suitable for WBR-style reporting and management reviews

**Decision Enabled**

* Weekly revenue can be used confidently for performance tracking and planning

---

### STEP 0.3 — Customer Value Foundations (RFM Base)

**Business Question**
Who are the most valuable customers, and how concentrated is revenue contribution?

**What was done**

* Built customer-level aggregates for:

  * Recency (last purchase date)
  * Frequency (distinct invoices)
  * Monetary value (total revenue)
* Materialized `uk_rfm_customers` for reuse

**Validated Results**

* Customers analyzed: **3,882**
* Average revenue per customer: **£1,520.74**
* Individual top customers contribute **£40k–£80k** each

**Business Interpretation**

* Revenue contribution is highly skewed but not fragile
* Strong signal for deeper segmentation and Pareto analysis

**Decision Enabled**

* Proceed with revenue concentration and lifecycle analysis rather than broad, untargeted marketing

---

### STEP 0.4 — Revenue Concentration (Pareto 80/20)

**Business Question**
Is the business overly dependent on a small elite customer base?

**Validated Results**

* Customers driving 80% of revenue: **1,224**
* Share of customer base: **31.53%**

**Business Interpretation**

* Revenue concentration is **moderate**, not extreme
* Business risk is diversified
* Significant upside exists in upgrading mid-tier customers

**Decision Enabled**

* Focus growth strategy on **mid-tier uplift**, not only VIP protection

---

### STEP 0.5 — Retention Cohort Foundations

**Business Question**
How durable are customer relationships after acquisition?

**What was done**

* Defined cohorts by first purchase month
* Tracked monthly customer retention

**Key Findings**

* Month-1 retention typically **15–35%**
* Retention stabilizes after early drop-off
* Strong evidence of **seasonal reactivation**, especially year-end

**Decision Enabled**

* Prioritize second-purchase acceleration and seasonal reactivation campaigns

---

### STEP 0 — Executive Summary (Locked)

* UK revenue data is **clean, complete, and forecast-ready**
* Customer value is **skewed but diversified**, reducing concentration risk
* Strong early churn exists, but **customers frequently return later**
* The largest opportunity lies in **post-acquisition monetization**, not acquisition volume alone

---

This canvas records each analytical step, results, and business interpretation to support an executive‑level summary at the end of the project.

---

## STEP 1 — Second‑Purchase Funnel Analysis

### Objective

Quantify early‑lifecycle drop‑off and identify the highest‑impact growth lever: **second‑purchase conversion**.

---

### STEP 1.1 — Transaction Normalization (UK Only)

**What was done**

* Parsed mixed date formats into a single timestamp
* Filtered to United Kingdom
* Preserved invoice‑level granularity

**Validation Result**

* Multiple rows per invoice observed → confirms line‑item data
* Invoice timestamps correctly ordered

**Conclusion**
Data is suitable for customer‑level purchase sequencing.

---

### STEP 1.2 — Purchase Sequencing per Customer

**What was done**

* Ranked invoices chronologically per customer
* Assigned purchase_number using ROW_NUMBER()

**Key Observation**

* Same invoice appears multiple times due to line items
* Confirms need to count DISTINCT invoice_no in funnel metrics

**Conclusion**
Purchase order logic is valid; deduplication handled at aggregation stage.

---

### STEP 1.3 — Purchase Count Distribution (Core Funnel)

**Metric**: Total distinct invoices per customer

| Purchases | Customers | % of Customers |
| --------- | --------- | -------------- |
| 1         | 1,348     | 34.72%         |
| 2         | 743       | 19.14%         |
| 3         | 453       | 11.67%         |
| 4         | 345       | 8.89%          |
| 5+        | 991       | 25.58%         |

**Key Insight**

* **~35% of customers churn after their first purchase**
* **~65% make at least a second purchase**
* Funnel drop is concentrated immediately after purchase #1

**Executive Interpretation**

> Revenue growth is constrained not by acquisition, but by weak second‑purchase conversion.

---

### Business Implication (Preliminary)

* Improving second‑purchase conversion by even **+5–10 pp** has a larger ROI than top‑of‑funnel acquisition
* This aligns with cohort findings showing steep Month‑1 churn

---

### STEP 1.4 — Second‑Purchase Conversion (Headline KPI)

**Metric**

* Customers with ≥2 purchases / total customers

**Result**

* Total customers: 3,882
* Repeat customers (≥2 purchases): 2,534
* **Second‑purchase conversion: 65.28%**

**Executive Interpretation**

> Nearly two‑thirds of acquired customers return at least once, indicating a strong core value proposition. Growth is constrained by *speed* of repeat, not intent.

---

### STEP 1.5 — Time to Second Purchase

**Metric**

* Days between first and second distinct invoice per customer

**Results**

* Repeat customers analyzed: 2,534
* **Median time to second purchase: 52.11 days**

**Conversion Speed Distribution**

| Window    | Customers | % of Repeat Customers |
| --------- | --------- | --------------------- |
| ≤ 7 days  | 331       | 13.06%                |
| ≤ 30 days | 845       | 33.35%                |
| ≤ 60 days | 1,383     | 54.58%                |

**Key Insight**

* Only **1 in 3 repeat customers convert within 30 days**
* Half of all repeat behavior happens **after ~2 months**

**Executive Interpretation**

> The primary retention constraint is not willingness to return, but *latency*. Customers eventually come back, but too slowly to maximize revenue velocity.

---

### STEP 1 — Executive Summary (Locked)

* Second‑purchase conversion is healthy (**65.28%**), indicating strong product‑market fit
* **Early‑lifecycle speed is weak**: median 52 days to repeat purchase
* Accelerating first → second purchase by even 15–20 days would materially increase cash flow, LTV realization, and forecast stability

**Strategic Lever Identified**: *Early repeat acceleration* (post‑purchase nudges, replenishment reminders, time‑bound offers)

---

## STEP 2 — RFM Segmentation (Data‑Driven Clustering)

### STEP 2.1 — RFM Distribution Summary

**Recency (days)**

* Min: 0 | P25: 17 | Median: 50 | P75: 143 | Max: 373

**Frequency & Monetary (median)**

* Median frequency: 2 purchases
* Median monetary value: £623.02

**Interpretation**

* Strong right‑skew in recency confirms long tail of dormant customers
* Frequency and spend are heavily concentrated in a small subset

---

### STEP 2.2–2.3 — Percentile‑Based Clustering

Customers were clustered using quartiles on Recency (ascending), Frequency (descending), and Monetary (descending), creating natural density groups without arbitrary thresholds.

**Largest Natural Clusters (by size)**

* (R1,F1,M1): 448 customers
* (R4,F4,M4): 340 customers
* (R4,F3,M3): 207 customers

This confirms **heterogeneous behavior** rather than a single dominant customer type.

---

### STEP 2.4 — Segment Performance Summary

| Segment       | Customers | Avg Revenue (£) | Total Revenue (£) |
| ------------- | --------: | --------------: | ----------------: |
| **Mid‑Tier**  |       917 |        4,381.69 |         4,018,009 |
| **At Risk**   |     1,776 |          523.69 |           930,076 |
| **Loyal**     |       854 |          631.85 |           539,600 |
| **Dormant**   |       164 |        2,223.42 |           364,640 |
| **Champions** |       171 |          299.40 |            51,197 |

---

### Key Insights

* **Mid‑Tier customers drive the majority of revenue**, not Champions
* “Champions” are highly recent/frequent but low‑spend — likely small‑basket buyers
* Revenue concentration risk is low; value is broadly distributed

### Executive Interpretation

> The highest ROI lever is **upgrading Mid‑Tier and At‑Risk customers**, not over‑investing in a small elite segment.

---

## STEP 3 — Revenue Retention & Cohort LTV (Repeat Revenue Only)

### STEP 3.1 — Revenue-Aware Purchase Sequencing

**What was done**

* Deduplicated to invoice level
* Ranked purchases per customer
* Explicitly separated first vs repeat purchases

**Validation**

* Purchase numbers increment correctly
* Invoice-level revenue aggregation is accurate

---

### STEP 3.2 — Repeat Revenue by Cohort Age

**Definition**

* Includes only purchases **after the first transaction**
* Measures monetization durability, not acquisition

**Key Observations**

* Earliest cohort (Dec 2010) shows **sustained repeat revenue across 12+ months**
* Repeat revenue does not decay monotonically; multiple secondary peaks observed
* Indicates seasonal reactivation and replenishment-driven behavior

**Illustrative Insight**

> Customers do not simply churn — many pause and return later with meaningful spend.

---

### STEP 3 — Executive Interpretation (Locked)

* Repeat revenue is **long-lived**, extending well beyond initial lifecycle months
* Monetization strength comes from **reactivation and long-tail repeat behavior**, not rapid early spending alone
* This explains why older cohorts continue to dominate revenue despite weaker recency scores

---

### STEP 3.3 — Cumulative Repeat LTV Curve

**What was measured**

* Cumulative repeat revenue generated by each cohort over lifecycle months
* Excludes first-purchase revenue entirely

**Key Results (Dec 2010 Cohort)**

* Cumulative repeat LTV crossed **£1.0M by month 5**
* Continued to grow steadily beyond **£1.7M by month 9**
* No clear saturation point within the observed window

**Insight**

> Customer value accrues gradually over time, with substantial revenue realized well after acquisition. Early performance significantly understates true lifetime value.

**Strategic Implication**

* Forecasts and ROI models must incorporate **delayed monetization**
* Investments in reactivation and cadence control have compounding returns

---

**Overall STEP 3 Conclusion**
Repeat revenue dynamics validate that this business is driven by **slow-burn, durable customer relationships**, not quick-hit transactions.

---

## STEP 4 — Revenue Decomposition (Monthly)

### Objective

Decompose monthly revenue into its fundamental drivers to identify which levers actually move top-line performance.

[ Revenue = Active Customers × Orders per Customer × AOV ]

---

### STEP 4.1 — Monthly Decomposition Results (UK)

| Month    | Active Customers | Orders / Customer | AOV (£) | Revenue (£) |
| -------- | ---------------: | ----------------: | ------: | ----------: |
| Dec 2010 |              805 |              1.57 |  331.87 |     418,826 |
| Jan 2011 |              635 |              1.34 |  357.99 |     305,007 |
| Feb 2011 |              667 |              1.31 |  354.48 |     309,106 |
| Mar 2011 |              865 |              1.33 |  346.50 |     398,475 |
| Apr 2011 |              774 |              1.33 |  334.46 |     344,156 |
| May 2011 |              947 |              1.44 |  348.26 |     476,415 |
| Jun 2011 |              879 |              1.39 |  319.32 |     389,575 |
| Jul 2011 |              847 |              1.38 |  352.67 |     413,332 |
| Aug 2011 |              822 |              1.34 |  367.51 |     403,893 |
| Sep 2011 |            1,128 |              1.35 |  420.52 |     642,549 |
| Oct 2011 |            1,219 |              1.37 |  410.80 |     684,398 |
| Nov 2011 |            1,492 |              1.57 |  371.71 |     869,048 |
| Dec 2011 |              551 |              1.25 |  361.02 |     248,743 |

---

### Key Insights

* **Active customers are the primary revenue driver**: major revenue spikes (Sep–Nov 2011) align with sharp increases in customer count
* **Orders per customer are remarkably stable** (~1.3–1.5) across months
* **AOV fluctuates**, but contributes less to volatility than customer volume

---

### Executive Interpretation (Locked)

> Revenue growth in this business is driven predominantly by **how many customers are active in a given month**, not by changes in purchase frequency or basket size.

---

### Strategic Implications

* Growth initiatives should prioritize **reactivating dormant customers and expanding the active base**
* Attempts to materially increase order frequency face structural limits
* AOV optimization is incremental, not transformational

---

**Overall STEP 4 Conclusion**
The single most powerful revenue lever is **active customer volume**. Frequency and AOV are secondary, relatively stable contributors.

---

## STEP 5 — Forecast Scenarios (Monthly Revenue Impact)

### Objective

Translate analytical insights into **clear, decision-ready revenue scenarios** using monthly impact estimates.

---

### Baseline (Observed)

Using recent stable months (Sep–Nov 2011):

* Average active customers ≈ **1,280**
* Orders per customer ≈ **1.43**
* AOV ≈ **£401**
* **Baseline monthly revenue ≈ £735K**

---

### Scenario 1 — +10% Active Customers (Primary Lever)

**Assumption**

* Reactivation + acquisition lift increases active customers by 10%

**Impact**

* Active customers: 1,408
* Monthly revenue uplift ≈ **+£73K**

**Interpretation**

> Even modest gains in customer activation produce large, immediate revenue impact.

---

### Scenario 2 — Faster Second Purchase (−15 Days Median)

**Assumption**

* Earlier repeat shifts ~10% of repeat revenue forward into the same month

**Impact**

* Monthly revenue uplift ≈ **+£40–50K** (timing acceleration, not net-new demand)

**Interpretation**

> This improves cash flow, forecast stability, and short-term KPIs without changing long-run LTV.

---

### Scenario 3 — +5% AOV (Secondary Lever)

**Assumption**

* Pricing / bundling increases average order value by 5%

**Impact**

* Monthly revenue uplift ≈ **+£37K**

**Interpretation**

> AOV optimization helps, but delivers smaller upside than customer activation.

---

### Scenario Ranking (Monthly Impact)

1. **Increase active customers** (~+£73K)
2. **Accelerate repeat purchase timing** (~+£45K)
3. **Increase AOV** (~+£37K)

---

### STEP 5 — Executive Summary (Final)

* The business has **strong product-market fit** but **slow monetization velocity**
* Revenue is driven primarily by **how many customers are active**, not how often they buy
* Customer value is **long-lived and back-loaded**, requiring patience in performance measurement
* The highest-ROI strategy is **reactivation + early repeat acceleration**, not aggressive discounting

---

## FINAL TAKEAWAY

> Sustainable revenue growth comes from **bringing more customers back, sooner**, rather than pushing existing customers to buy more in a single visit.

This completes the end-to-end analytics narrative from raw data to executive decision-making.*


---

## Resume bullets
- Built an end-to-end retail analytics pipeline in PostgreSQL, replacing Python notebook logic with reusable CTEs and materialized views across 374 days of UK transaction data.

- Identified second-purchase latency (median 52 days) as the primary revenue bottleneck despite a healthy 65.28% repeat-purchase rate, shifting focus from acquisition to post-purchase acceleration.

- Performed RFM segmentation and Pareto analysis on 3,882 customers, showing 31.5% of customers generate 80% of revenue, indicating moderate concentration and strong mid-tier growth potential.

- Designed monthly cohort and repeat-revenue LTV models, demonstrating that customer value is long-lived and back-loaded, with cumulative repeat LTV exceeding £1.7M for early cohorts.

- Decomposed revenue into Active Customers × Frequency × AOV, proving that customer activation volume is the dominant revenue lever.

- Quantified business impact via scenario modeling, showing a 10% increase in active customers drives ~£73K incremental monthly revenue, outperforming pricing or frequency-based strategies.