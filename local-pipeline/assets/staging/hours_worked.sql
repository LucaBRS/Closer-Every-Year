/* @bruin
name: staging.hours_worked
type: duckdb.sql
connection: main_db
depends:
  - load.hours_worked
materialization:
  type: table
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: hours_worked_m
    checks:
      - name: non_negative
  - name: hours_worked_f
    checks:
      - name: non_negative
  - name: hours_worked_delta
    description: "hours_worked_m - hours_worked_f — can be negative when women work more hours than men on average"
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
