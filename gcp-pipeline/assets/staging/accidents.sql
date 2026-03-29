/* @bruin
name: staging.accidents
type: bq.sql
connection: gcp_conn
depends:
  - load.accidents
materialization:
  type: table
  strategy: merge
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: accidents_m
  - name: accidents_f
@bruin */

SELECT
    a.country,
    a.year,
    SUM(CASE WHEN a.sex = 'M' THEN a.accidents END) AS accidents_m,
    SUM(CASE WHEN a.sex = 'F' THEN a.accidents END) AS accidents_f
FROM load.accidents AS a
GROUP BY a.country, a.year
