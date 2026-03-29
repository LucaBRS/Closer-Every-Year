/* @bruin
name: staging.accidents
type: duckdb.sql
connection: main_db
depends:
  - load.accidents
materialization:
  type: table
@bruin */

SELECT
    country,
    year,
    SUM(CASE WHEN sex = 'M' THEN accidents END) AS accidents_m,
    SUM(CASE WHEN sex = 'F' THEN accidents END) AS accidents_f
FROM load.accidents
GROUP BY country, year
