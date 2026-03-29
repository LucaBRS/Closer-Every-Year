/* @bruin
name: analytics.gender_gap
type: duckdb.sql
connection: main_db
depends:
  - staging.hours_worked
  - staging.gender_pay_gap
  - staging.accidents
  - staging.employed
materialization:
  type: table
@bruin */

SELECT
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
ORDER BY h.country, h.year
