CREATE OR REPLACE TABLE DIM_DATE AS
SELECT DISTINCT
    report_date AS date_key,
    YEAR(report_date) AS year,
    MONTH(report_date) AS month,
    DAY(report_date) AS day
FROM STG_ECDC_DEDUP;

CREATE OR REPLACE TABLE DIM_COUNTRY AS
SELECT DISTINCT
    country,
    country_iso,
    continent,
    population
FROM STG_ECDC_DEDUP;
