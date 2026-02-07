-- Second-Purchase Funnel

--STEP 1.1 — Normalize Transactions (Reuse Pattern)
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
)
SELECT *
FROM uk_txn
LIMIT 10;

-- STEP 1.2 — Purchase Order per Customer
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
ranked_purchases AS (
  SELECT
    customer_id,
    invoice_no,
    invoice_ts,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY invoice_ts
    ) AS purchase_number
  FROM uk_txn
)
SELECT *
FROM ranked_purchases
WHERE purchase_number <= 3
ORDER BY customer_id, purchase_number
LIMIT 10;



-- STEP 1.3 — Purchase Count Distribution
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no,
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
purchase_counts AS (
  SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS total_purchases
  FROM uk_txn
  GROUP BY customer_id
)
SELECT
  total_purchases,
  COUNT(*) AS customers,
  ROUND(
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
    2
  ) AS customer_pct
FROM purchase_counts
GROUP BY total_purchases
ORDER BY total_purchases
limit 10;


--STEP 1.4 — Second-Purchase Conversion Rate
WITH uk_txn AS (
  SELECT
    customer_id,
    invoice_no
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
purchase_counts AS (
  SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS total_purchases
  FROM uk_txn
  GROUP BY customer_id
)
SELECT
  COUNT(*) AS total_customers,
  COUNT(*) FILTER (WHERE total_purchases >= 2) AS repeat_customers,
  ROUND(
    COUNT(*) FILTER (WHERE total_purchases >= 2) * 100.0 / COUNT(*),
    2
  ) AS second_purchase_conversion_pct
FROM purchase_counts;


-- STEP 1.5 — Time to Second Purchase

-- STEP 1.5.1 — Deduplicate to Invoice-Level
WITH uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    MIN(
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    ) AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
  GROUP BY customer_id, invoice_no
)
SELECT *
FROM uk_invoices
ORDER BY customer_id, invoice_ts
LIMIT 10;


--STEP 1.5.2 — Identify First & Second Purchase per Customer
WITH uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    MIN(
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    ) AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
  GROUP BY customer_id, invoice_no
),
ranked_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    invoice_ts,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY invoice_ts
    ) AS purchase_number
  FROM uk_invoices
)
SELECT *
FROM ranked_invoices
WHERE purchase_number <= 2
ORDER BY customer_id, purchase_number;

-- STEP 1.5.3 — Time to Second Purchase (Days)
WITH uk_invoices AS (
    SELECT 
        customer_id,
        invoice_no,
        MIN(
            CASE 
                WHEN invoice_date LIKE '__-__-____%' 
                THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
                ELSE invoice_date::timestamp
            END
        ) AS invoice_ts
    FROM online_retail_final
    WHERE country = 'United Kingdom'
    GROUP BY customer_id, invoice_no
),
ranked_invoices AS (
    SELECT 
        customer_id,
        invoice_ts,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY invoice_ts
        ) AS purchase_number
    FROM uk_invoices
),
first_second AS (
    SELECT 
        customer_id,
        MAX(invoice_ts) FILTER (WHERE purchase_number = 1) AS first_ts,
        MAX(invoice_ts) FILTER (WHERE purchase_number = 2) AS second_ts
    FROM ranked_invoices
    GROUP BY customer_id
),
diffs AS (
    SELECT 
        customer_id,
        (EXTRACT(EPOCH FROM (second_ts - first_ts)) / 86400.0)::NUMERIC AS days_to_second
    FROM first_second
    WHERE second_ts IS NOT NULL
)
SELECT 
    COUNT(*) AS repeat_customers,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_to_second)::NUMERIC,
        2
    ) AS median_days_to_second_purchase
FROM diffs;


-- STEP 1.5.4 — Conversion Speed Buckets (Correct & Safe)
WITH uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    MIN(
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    ) AS invoice_ts
  FROM online_retail_final
  WHERE country = 'United Kingdom'
  GROUP BY customer_id, invoice_no
),
ranked_invoices AS (
  SELECT
    customer_id,
    invoice_ts,
    ROW_NUMBER() OVER (
      PARTITION BY customer_id
      ORDER BY invoice_ts
    ) AS purchase_number
  FROM uk_invoices
),
first_second AS (
  SELECT
    customer_id,
    MAX(invoice_ts) FILTER (WHERE purchase_number = 1) AS first_ts,
    MAX(invoice_ts) FILTER (WHERE purchase_number = 2) AS second_ts
  FROM ranked_invoices
  GROUP BY customer_id
),
diffs AS (
  SELECT
    EXTRACT(EPOCH FROM (second_ts - first_ts)) / 86400.0 AS days_to_second
  FROM first_second
  WHERE second_ts IS NOT NULL
)
SELECT
  COUNT(*) AS repeat_customers,
  COUNT(*) FILTER (WHERE days_to_second <= 7)  AS within_7_days,
  COUNT(*) FILTER (WHERE days_to_second <= 30) AS within_30_days,
  COUNT(*) FILTER (WHERE days_to_second <= 60) AS within_60_days,
  ROUND(
    COUNT(*) FILTER (WHERE days_to_second <= 30) * 100.0 / COUNT(*),
    2
  ) AS pct_within_30_days
FROM diffs;





-- STEP 2 — RFM Segmentation

--STEP 2.1 — Inspect RFM Distributions (Sanity Check)
SELECT
  MIN(recency_days) AS min_recency,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY recency_days) AS p25_recency,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY recency_days) AS median_recency,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY recency_days) AS p75_recency,
  MAX(recency_days) AS max_recency,

  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY frequency) AS median_frequency,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY monetary) AS median_monetary
FROM uk_rfm_customers;


--STEP 2.2 — Percentile Bucketing (Core Clustering Logic)
WITH scored AS (
  SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,

    NTILE(4) OVER (ORDER BY recency_days ASC)  AS r_bucket,
    NTILE(3) OVER (ORDER BY frequency DESC)    AS f_bucket,
    NTILE(4) OVER (ORDER BY monetary DESC)     AS m_bucket
  FROM uk_rfm_customers
)
SELECT
  r_bucket,
  f_bucket,
  m_bucket,
  COUNT(*) AS customers
FROM scored
GROUP BY r_bucket, f_bucket, m_bucket
ORDER BY customers DESC
limit 10;


-- STEP 2.3 — RFM Cluster Formation
WITH scored AS (
  SELECT
    customer_id,
    NTILE(4) OVER (ORDER BY recency_days ASC)  AS r,
    NTILE(4) OVER (ORDER BY frequency DESC)    AS f,
    NTILE(4) OVER (ORDER BY monetary DESC)     AS m
  FROM uk_rfm_customers
)
SELECT
  r, f, m,
  COUNT(*) AS customers
FROM scored
GROUP BY r, f, m
ORDER BY customers DESC
LIMIT 10;


-- STEP 2.4 — Segment Labeling (Business Translation)
WITH scored AS (
  SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY recency_days ASC)  AS r,
    NTILE(4) OVER (ORDER BY frequency DESC)    AS f,
    NTILE(4) OVER (ORDER BY monetary DESC)     AS m
  FROM uk_rfm_customers
),
segmented AS (
  SELECT
    *,
    CASE
      WHEN r = 1 AND f >= 3 AND m >= 3 THEN 'Champions'
      WHEN r <= 2 AND f >= 2 AND m >= 2 THEN 'Loyal'
      WHEN r >= 3 AND f >= 2 THEN 'At Risk'
      WHEN r >= 3 AND f = 1 THEN 'Dormant'
      ELSE 'Mid-Tier'
    END AS segment
  FROM scored
)
SELECT
  segment,
  COUNT(*) AS customers,
  ROUND(AVG(monetary), 2) AS avg_revenue,
  ROUND(SUM(monetary), 2) AS total_revenue
FROM segmented
GROUP BY segment
ORDER BY total_revenue DESC;
