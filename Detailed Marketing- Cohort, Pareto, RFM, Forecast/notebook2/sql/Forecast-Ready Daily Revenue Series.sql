-- STEP 8 — Forecasting Dataset

-- 8.1 — Build Forecast-Ready Daily Series (CTE)
WITH calendar AS (
  SELECT
    generate_series(
      MIN(invoice_date),
      MAX(invoice_date),
      INTERVAL '1 day'
    )::DATE AS ds
  FROM uk_daily_revenue
),
daily AS (
  SELECT
    invoice_date AS ds,
    daily_revenue AS y
  FROM uk_daily_revenue
)
SELECT
  c.ds,
  COALESCE(d.y, 0) AS y
FROM calendar c
LEFT JOIN daily d
  ON c.ds = d.ds
ORDER BY c.ds;


-- sanity checks
SELECT
  COUNT(*) AS days,
  SUM(CASE WHEN y = 0 THEN 1 ELSE 0 END) AS zero_revenue_days,
  MIN(ds) AS start_date,
  MAX(ds) AS end_date
FROM (
  WITH calendar AS (
    SELECT
      generate_series(
        MIN(invoice_date),
        MAX(invoice_date),
        INTERVAL '1 day'
      )::DATE AS ds
    FROM uk_daily_revenue
  )
  SELECT
    c.ds,
    COALESCE(d.daily_revenue, 0) AS y
  FROM calendar c
  LEFT JOIN uk_daily_revenue d
    ON c.ds = d.invoice_date
) x;

