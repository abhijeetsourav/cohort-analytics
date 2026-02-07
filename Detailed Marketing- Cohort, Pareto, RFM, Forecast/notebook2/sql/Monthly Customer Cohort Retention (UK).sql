--7.1 — Build Retention Cohort Matrix (CTE only)
WITH uk_txn AS (
  SELECT
    customer_id,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),

-- 1️⃣ First purchase month per customer (cohort definition)
customer_cohort AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', MIN(invoice_ts))::DATE AS cohort_month
  FROM uk_txn
  GROUP BY customer_id
),

-- 2️⃣ Monthly activity per customer
monthly_activity AS (
  SELECT
    t.customer_id,
    DATE_TRUNC('month', t.invoice_ts)::DATE AS activity_month,
    c.cohort_month
  FROM uk_txn t
  JOIN customer_cohort c
    ON t.customer_id = c.customer_id
),

-- 3️⃣ Cohort index (months since first purchase)
cohort_indexed AS (
  SELECT
    cohort_month,
    activity_month,
    (
      (DATE_PART('year', activity_month) - DATE_PART('year', cohort_month)) * 12 +
      (DATE_PART('month', activity_month) - DATE_PART('month', cohort_month))
    )::INT AS cohort_index,
    customer_id
  FROM monthly_activity
),

-- 4️⃣ Active customers per cohort/month
cohort_counts AS (
  SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM cohort_indexed
  GROUP BY cohort_month, cohort_index
),

-- 5️⃣ Cohort sizes (Month 0 baseline)
cohort_sizes AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size
  FROM customer_cohort
  GROUP BY cohort_month
)

-- 6️⃣ Retention rate
SELECT
  cc.cohort_month,
  cc.cohort_index,
  cc.active_customers,
  cs.cohort_size,
  ROUND(
    cc.active_customers::NUMERIC / cs.cohort_size,
    4
  ) AS retention_rate
FROM cohort_counts cc
JOIN cohort_sizes cs
  ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.cohort_index;

-- sanity check
WITH uk_txn AS (
  SELECT
    customer_id,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
customer_cohort AS (
  SELECT
    customer_id,
    DATE_TRUNC('month', MIN(invoice_ts))::DATE AS cohort_month
  FROM uk_txn
  GROUP BY customer_id
),
monthly_activity AS (
  SELECT
    t.customer_id,
    DATE_TRUNC('month', t.invoice_ts)::DATE AS activity_month,
    c.cohort_month
  FROM uk_txn t
  JOIN customer_cohort c
    ON t.customer_id = c.customer_id
),
cohort_indexed AS (
  SELECT
    cohort_month,
    (
      (DATE_PART('year', activity_month) - DATE_PART('year', cohort_month)) * 12 +
      (DATE_PART('month', activity_month) - DATE_PART('month', cohort_month))
    )::INT AS cohort_index,
    customer_id
  FROM monthly_activity
),
cohort_counts AS (
  SELECT
    cohort_month,
    cohort_index,
    COUNT(DISTINCT customer_id) AS active_customers
  FROM cohort_indexed
  GROUP BY cohort_month, cohort_index
),
cohort_sizes AS (
  SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size
  FROM customer_cohort
  GROUP BY cohort_month
)
SELECT
  cc.cohort_month,
  cc.cohort_index,
  cc.active_customers,
  cs.cohort_size,
  ROUND(cc.active_customers::NUMERIC / cs.cohort_size, 4) AS retention_rate
FROM cohort_counts cc
JOIN cohort_sizes cs
  ON cc.cohort_month = cs.cohort_month
WHERE cc.cohort_index <= 3
ORDER BY cc.cohort_month, cc.cohort_index;
