/* @bruin
name: staging.employed
type: duckdb.sql
connection: main_db
depends:
  - load.employed
materialization:
  type: table
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: employed_m
    checks:
      - name: non_negative
  - name: employed_f
    checks:
      - name: non_negative
@bruin */

SELECT
    country,
    year,
    AVG(CASE WHEN sex = 'M' THEN employed END) AS employed_m,
    AVG(CASE WHEN sex = 'F' THEN employed END) AS employed_f
FROM load.employed
GROUP BY country, year
