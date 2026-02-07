-- STEP 1 — Daily Revenue with Safe Date Handling
WITH uk_data AS (
  SELECT
    customer_id,
    invoice_no,
    CASE
      WHEN invoice_date LIKE '__-__-____%' 
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts,
    total_price
  FROM online_retail_final
  WHERE country = 'United Kingdom'
),
daily_revenue AS (
  SELECT
    invoice_ts::DATE AS invoice_date,
    SUM(total_price) AS daily_revenue
  FROM uk_data
  GROUP BY 1
)
SELECT *
FROM daily_revenue
ORDER BY invoice_date
LIMIT 10;


-- STEP 2 — Create Materialized View: Daily Revenue (UK)
CREATE MATERIALIZED VIEW uk_daily_revenue AS
WITH uk_data AS (
  SELECT
    CASE
      WHEN invoice_date LIKE '__-__-____%'
        THEN TO_TIMESTAMP(invoice_date, 'DD-MM-YYYY HH24:MI')
      ELSE
        invoice_date::timestamp
    END AS invoice_ts,
    total_price
  FROM online_retail_final
  WHERE country = 'United Kingdom'
)
SELECT
  invoice_ts::DATE AS invoice_date,
  SUM(total_price) AS daily_revenue
FROM uk_data
GROUP BY 1
ORDER BY 1;


SELECT COUNT(*) AS days, MIN(invoice_date), MAX(invoice_date)
FROM uk_daily_revenue;


-- STEP 3 — Create Weekly Revenue (Materialized View)
CREATE MATERIALIZED VIEW uk_weekly_revenue AS
SELECT
  DATE_TRUNC('week', invoice_date)::DATE AS week_start,
  SUM(daily_revenue) AS weekly_revenue
FROM uk_daily_revenue
GROUP BY 1
ORDER BY 1;

SELECT COUNT(*) AS weeks, MIN(week_start), MAX(week_start)
FROM uk_weekly_revenue;

