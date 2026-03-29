/* @bruin
name: staging.gender_pay_gap
type: duckdb.sql
connection: main_db
depends:
  - load.gender_pay_gap
materialization:
  type: table
@bruin */
SELECT country, year, gender_pay_gap
FROM load.gender_pay_gap