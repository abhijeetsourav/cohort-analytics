-- STEP 4 — Revenue Decomposition

-- STEP 4.1 — Monthly Invoice-Level Base (UK)
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
    DATE_TRUNC('month', MIN(invoice_ts))::DATE AS month,
    SUM(total_price) AS invoice_revenue
  FROM uk_txn
  GROUP BY customer_id, invoice_no
)
SELECT *
FROM uk_invoices
ORDER BY month, customer_id
LIMIT 10;


-- STEP 4.2 — Monthly Revenue & Active Customers
WITH uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    DATE_TRUNC('month',
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    )::DATE AS month,
    total_price
  FROM online_retail_final
  WHERE country = 'United Kingdom'
)
SELECT
  month,
  COUNT(DISTINCT customer_id) AS active_customers,
  SUM(total_price) AS total_revenue
FROM uk_invoices
GROUP BY month
ORDER BY month;


-- STEP 4.3 — Monthly Purchase Frequency (Orders per Customer)
WITH uk_invoices AS (
  SELECT
    customer_id,
    invoice_no,
    DATE_TRUNC('month',
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    )::DATE AS month
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
monthly_orders AS (
  SELECT
    month,
    customer_id,
    COUNT(DISTINCT invoice_no) AS orders
  FROM uk_invoices
  GROUP BY month, customer_id
)
SELECT
  month,
  ROUND(AVG(orders), 2) AS avg_orders_per_customer
FROM monthly_orders
GROUP BY month
ORDER BY month;


-- STEP 4.4 — Monthly AOV (Average Order Value)
WITH uk_txn AS (
  SELECT
    invoice_no,
    total_price,
    DATE_TRUNC('month',
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    )::DATE AS month
  FROM online_retail_final
  WHERE country = 'United Kingdom'
)
SELECT
  month,
  ROUND(SUM(total_price) / COUNT(DISTINCT invoice_no), 2) AS aov
FROM uk_txn
GROUP BY month
ORDER BY month;



-- STEP 4.5 — Full Monthly Decomposition (Executive Table)
WITH base AS (
  SELECT
    DATE_TRUNC('month',
      CASE
        WHEN invoice_date LIKE '__-__-____%'
          THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
        ELSE
          invoice_date::timestamp
      END
    )::DATE AS month,
    customer_id,
    invoice_no,
    total_price
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
agg AS (
  SELECT
    month,
    COUNT(DISTINCT customer_id) AS active_customers,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(total_price) AS revenue
  FROM base
  GROUP BY month
)
SELECT
  month,
  active_customers,
  ROUND(total_orders::NUMERIC / active_customers, 2) AS orders_per_customer,
  ROUND(revenue / total_orders, 2) AS aov,
  revenue
FROM agg
ORDER BY month;