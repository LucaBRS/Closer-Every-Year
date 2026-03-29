/* @bruin
name: analytics.gender_gap
type: bq.sql
connection: gcp_conn
depends:
  - staging.hours_worked
  - staging.gender_pay_gap
  - staging.accidents
  - staging.employed
materialization:
  type: table
  strategy: merge
  partition_by: year_date
  cluster_by:
    - country
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: year_date
  - name: hours_worked_m
  - name: hours_worked_f
  - name: hours_worked_delta
  - name: gender_pay_gap
  - name: accidents_m
  - name: accidents_f
  - name: employed_m
  - name: employed_f
@bruin */

SELECT
    DATE(h.year, 12, 31) AS year_date,
    h.country,
    h.year,
    h.hours_worked_m,
    h.hours_worked_f,
    h.hours_worked_delta,
    g.gender_pay_gap,
    ac.accidents_m,
    ac.accidents_f,
    e.employed_m,
    e.employed_f
FROM staging.hours_worked h
LEFT JOIN staging.gender_pay_gap g
    ON h.country = g.country AND h.year = g.year
LEFT JOIN staging.accidents ac
    ON h.country = ac.country AND h.year = ac.year
LEFT JOIN staging.employed e
    ON h.country = e.country AND h.year = e.year
