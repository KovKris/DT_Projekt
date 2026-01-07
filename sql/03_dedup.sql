CREATE OR REPLACE TABLE STG_ECDC_DEDUP AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY report_date, country
               ORDER BY last_update DESC
           ) AS rn
    FROM STG_ECDC_CLEAN
)
WHERE rn = 1;
