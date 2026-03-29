/* @bruin
name: staging.hours_worked
type: duckdb.sql
connection: main_db
depends:
  - load.hours_worked
materialization:
  type: table
@bruin */

SELECT
    country,
    year,
    AVG(CASE WHEN sex = 'M' THEN hours_worked END) AS hours_worked_m,
    AVG(CASE WHEN sex = 'F' THEN hours_worked END) AS hours_worked_f,
    AVG(CASE WHEN sex = 'M' THEN hours_worked END)
        - AVG(CASE WHEN sex = 'F' THEN hours_worked END) AS hours_worked_delta
FROM load.hours_worked
GROUP BY country, year
