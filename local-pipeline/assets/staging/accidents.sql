/* @bruin
name: staging.accidents
type: duckdb.sql
connection: main_db
depends:
  - load.accidents
materialization:
  type: table
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: accidents_m
    checks:
      - name: non_negative
  - name: accidents_f
    checks:
      - name: non_negative
@bruin */

SELECT
    country,
    year,
    SUM(CASE WHEN sex = 'M' THEN accidents END) AS accidents_m,
    SUM(CASE WHEN sex = 'F' THEN accidents END) AS accidents_f
FROM load.accidents
GROUP BY country, year
