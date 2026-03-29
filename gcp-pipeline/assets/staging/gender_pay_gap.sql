/* @bruin
name: staging.gender_pay_gap
type: bq.sql
connection: gcp_conn
depends:
  - load.gender_pay_gap
materialization:
  type: table
  strategy: merge
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: gender_pay_gap
@bruin */

SELECT t.country, t.year, t.gender_pay_gap
FROM load.gender_pay_gap AS t
