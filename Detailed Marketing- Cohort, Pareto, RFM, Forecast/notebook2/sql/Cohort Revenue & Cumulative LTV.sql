-- STEP 3 — Revenue Retention & Cohort LTV

-- STEP 3.1 — Build Cohorts + Purchase Order (Revenue-Aware)
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no,
    total_price,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),

-- 1️⃣ Deduplicate to invoice level
uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    MIN(invoice_ts) AS invoice_ts,
    SUM(total_price) AS invoice_revenue
  FROM uk_txn
  GROUP BY customer_id, invoice_no
),

-- 2️⃣ Rank purchases per customer
ranked_invoices AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY invoice_ts
    ) AS purchase_number
  FROM uk_invoices
),

-- 3️⃣ First purchase month = cohort
customer_cohort AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', MIN(invoice_ts))::DATE AS cohort_month
  FROM ranked_invoices
  GROUP BY customer_id
)

SELECT *
FROM ranked_invoices
LIMIT 10;


-- STEP 3.2 — Repeat Revenue Only by Cohort Age
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no,
    total_price,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    MIN(invoice_ts) AS invoice_ts,
    SUM(total_price) AS invoice_revenue
  FROM uk_txn
  GROUP BY customer_id, invoice_no
),
ranked_invoices AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY invoice_ts
    ) AS purchase_number
  FROM uk_invoices
),
customer_cohort AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', MIN(invoice_ts))::DATE AS cohort_month
  FROM ranked_invoices
  GROUP BY customer_id
),
repeat_revenue AS (
  SELECT
    r.customer_id,
    c.cohort_month,
    DATE_TRUNC('month', r.invoice_ts)::DATE AS revenue_month,
    r.invoice_revenue
  FROM ranked_invoices r
  JOIN customer_cohort c
    ON r.customer_id = c.customer_id
  WHERE r.purchase_number > 1
),
cohort_lifecycle AS (
  SELECT
    cohort_month,
    (
      (DATE_PART('year', revenue_month) - DATE_PART('year', cohort_month)) * 12 +
      (DATE_PART('month', revenue_month) - DATE_PART('month', cohort_month))
    )::INT AS cohort_index,
    SUM(invoice_revenue) AS repeat_revenue
  FROM repeat_revenue
  GROUP BY cohort_month, cohort_index
)
SELECT
  cohort_month,
  cohort_index,
  repeat_revenue
FROM cohort_lifecycle
ORDER BY cohort_month, cohort_index;

-- ## STEP 3.3 — Cumulative Repeat LTV Curve
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no,
    total_price,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),

-- 1️⃣ Invoice-level deduplication
uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    MIN(invoice_ts) AS invoice_ts,
    SUM(total_price) AS invoice_revenue
  FROM uk_txn
  GROUP BY customer_id, invoice_no
),

-- 2️⃣ Purchase ranking
ranked_invoices AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY invoice_ts
    ) AS purchase_number
  FROM uk_invoices
),

-- 3️⃣ Cohort definition
customer_cohort AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', MIN(invoice_ts))::DATE AS cohort_month
  FROM ranked_invoices
  GROUP BY customer_id
),

-- 4️⃣ Repeat revenue only
repeat_revenue AS (
  SELECT
    r.customer_id,
    c.cohort_month,
    DATE_TRUNC('month', r.invoice_ts)::DATE AS revenue_month,
    r.invoice_revenue
  FROM ranked_invoices r
  JOIN customer_cohort c
    ON r.customer_id = c.customer_id
  WHERE r.purchase_number > 1
),

-- 5️⃣ Cohort lifecycle aggregation
cohort_lifecycle AS (
  SELECT
    cohort_month,
    (
      (DATE_PART('year', revenue_month) - DATE_PART('year', cohort_month)) * 12 +
      (DATE_PART('month', revenue_month) - DATE_PART('month', cohort_month))
    )::INT AS cohort_index,
    SUM(invoice_revenue) AS repeat_revenue
  FROM repeat_revenue
  GROUP BY cohort_month, cohort_index
)

-- 6️⃣ Cumulative repeat LTV
SELECT
  cohort_month,
  cohort_index,
  repeat_revenue,
  SUM(repeat_revenue) OVER (
    PARTITION BY cohort_month
    ORDER BY cohort_index
  ) AS cumulative_repeat_ltv
FROM cohort_lifecycle
ORDER BY cohort_month, cohort_index
limit 10;