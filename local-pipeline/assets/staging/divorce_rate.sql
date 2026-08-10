/* @bruin
name: staging.divorce_rate
type: duckdb.sql
connection: main_db
depends:
  - load.divorce_rate
materialization:
  type: table
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: divorce_rate
    checks:
      - name: non_negative
@bruin */
SELECT country, year, divorce_rate
FROM load.divorce_rate