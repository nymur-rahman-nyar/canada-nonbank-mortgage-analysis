

.mode csv
.separator ","
.headers on


DROP TABLE IF EXISTS mortgages_raw;

CREATE TABLE mortgages_raw (
  REF_DATE TEXT,
  GEO TEXT,
  DGUID TEXT,
  lender_type TEXT,
  characteristic TEXT,
  metric TEXT,
  UOM TEXT,
  UOM_ID TEXT,
  SCALAR_FACTOR TEXT,
  SCALAR_ID TEXT,
  VECTOR TEXT,
  COORDINATE TEXT,
  VALUE TEXT,
  STATUS TEXT,
  SYMBOL TEXT,
  TERMINATED TEXT,
  DECIMALS TEXT
);


.import 


.once processed_sql_data/nonbank_delinquency_rates.csv

WITH src AS (
  SELECT
    date(REF_DATE || '-01') AS date,
    lender_type,
    metric,
    UOM,
    characteristic,
    CAST(VALUE AS REAL) AS value_num
  FROM mortgages_raw
  WHERE GEO = 'Canada'
    AND lender_type = 'All non-bank lenders'
    AND metric = 'Number of mortgages outstanding'
    AND UOM = 'Number'
    AND characteristic IN (
      'Total insured outstanding residential mortgages',
      'Total uninsured outstanding residential mortgages by loan-to-value (LTV) ratio',
      'Total insured residential mortgages in arrears by days in arrears',
      'Total uninsured residential mortgages in arrears by days in arrears',
      'Over 90 days, insured residential mortgages in arrears by days in arrears',
      'Over 90 days, uninsured residential mortgages in arrears by days in arrears'
    )
),
p AS (
  SELECT
    date,
    SUM(CASE WHEN characteristic = 'Total insured outstanding residential mortgages'
             THEN value_num END) AS insured_outstanding_num,
    SUM(CASE WHEN characteristic = 'Total uninsured outstanding residential mortgages by loan-to-value (LTV) ratio'
             THEN value_num END) AS uninsured_outstanding_num,

    SUM(CASE WHEN characteristic = 'Total insured residential mortgages in arrears by days in arrears'
             THEN value_num END) AS insured_arrears_num,
    SUM(CASE WHEN characteristic = 'Total uninsured residential mortgages in arrears by days in arrears'
             THEN value_num END) AS uninsured_arrears_num,

    SUM(CASE WHEN characteristic = 'Over 90 days, insured residential mortgages in arrears by days in arrears'
             THEN value_num END) AS insured_over90_arrears_num,
    SUM(CASE WHEN characteristic = 'Over 90 days, uninsured residential mortgages in arrears by days in arrears'
             THEN value_num END) AS uninsured_over90_arrears_num
  FROM src
  GROUP BY date
)
SELECT
  date,
  insured_outstanding_num,
  uninsured_outstanding_num,
  insured_arrears_num,
  uninsured_arrears_num,

  ROUND(100.0 * insured_arrears_num / NULLIF(insured_outstanding_num, 0), 4) AS insured_delinquency_rate_pct,
  ROUND(100.0 * uninsured_arrears_num / NULLIF(uninsured_outstanding_num, 0), 4) AS uninsured_delinquency_rate_pct,

  ROUND(100.0 * insured_over90_arrears_num / NULLIF(insured_outstanding_num, 0), 4) AS insured_over90_rate_pct,
  ROUND(100.0 * uninsured_over90_arrears_num / NULLIF(uninsured_outstanding_num, 0), 4) AS uninsured_over90_rate_pct
FROM p
WHERE date IS NOT NULL
ORDER BY date
;

.once stdout
.quit
