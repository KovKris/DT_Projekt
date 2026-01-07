CREATE OR REPLACE TABLE FACT_COVID_STATS AS
SELECT
    d.date_key,
    c.country,
    c.continent,
    s.cases,
    s.deaths,
    SUM(s.cases) OVER (
        PARTITION BY c.country
        ORDER BY d.date_key
    ) AS cumulative_cases,
    LAG(s.cases) OVER (
        PARTITION BY c.country
        ORDER BY d.date_key
    ) AS previous_day_cases,
    s.cases - LAG(s.cases) OVER (
        PARTITION BY c.country
        ORDER BY d.date_key
    ) AS daily_case_change
FROM STG_ECDC_DEDUP s
JOIN DIM_DATE d ON s.report_date = d.date_key
JOIN DIM_COUNTRY c ON s.country = c.country;
