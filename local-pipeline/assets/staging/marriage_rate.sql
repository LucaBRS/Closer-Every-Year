/* @bruin
name: staging.marriage_rate
type: duckdb.sql
connection: main_db
depends:
  - load.marriage_rate
materialization:
  type: table
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: marriage_rate
    checks:
      - name: non_negative
@bruin */
SELECT country, year, marriage_rate
FROM load.marriage_rate