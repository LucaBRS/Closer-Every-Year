/* @bruin
name: staging.gender_pay_gap
type: duckdb.sql
connection: main_db
depends:
  - load.gender_pay_gap
materialization:
  type: table
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: gender_pay_gap
    description: "% pay gap — can be negative in countries/years where women earn more than men on average"
@bruin */
SELECT country, year, gender_pay_gap
FROM load.gender_pay_gap