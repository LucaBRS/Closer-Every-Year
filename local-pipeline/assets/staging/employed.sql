/* @bruin
name: staging.employed
type: duckdb.sql
connection: main_db
depends:
  - load.employed
materialization:
  type: table
@bruin */

SELECT
    country,
    year,
    AVG(CASE WHEN sex = 'M' THEN employed END) AS employed_m,
    AVG(CASE WHEN sex = 'F' THEN employed END) AS employed_f
FROM load.employed
GROUP BY country, year
