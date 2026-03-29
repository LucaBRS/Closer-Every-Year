/* @bruin
name: staging.age_at_marriage
type: duckdb.sql
connection: main_db
depends:
  - load.age_at_marriage
materialization:
  type: table
@bruin */
SELECT
country,
year,
    AVG(CASE WHEN indic_de = 'FAGEMAR1' THEN age_at_marriage END) AS age_at_marriage_f,
    AVG(CASE WHEN indic_de = 'MAGEMAR1' THEN age_at_marriage END) AS age_at_marriage_m
FROM load.age_at_marriage
GROUP BY country, year
ORDER BY country, year