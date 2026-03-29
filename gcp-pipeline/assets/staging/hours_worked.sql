/* @bruin
name: staging.hours_worked
type: bq.sql
connection: gcp_conn
depends:
  - load.hours_worked
materialization:
  type: table
  strategy: merge
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: hours_worked_m
  - name: hours_worked_f
  - name: hours_worked_delta
@bruin */

SELECT
    h.country,
    h.year,
    AVG(CASE WHEN h.sex = 'M' THEN h.hours_worked END) AS hours_worked_m,
    AVG(CASE WHEN h.sex = 'F' THEN h.hours_worked END) AS hours_worked_f,
    AVG(CASE WHEN h.sex = 'M' THEN h.hours_worked END)
        - AVG(CASE WHEN h.sex = 'F' THEN h.hours_worked END) AS hours_worked_delta
FROM load.hours_worked AS h
GROUP BY h.country, h.year
