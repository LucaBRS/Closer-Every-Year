/* @bruin
name: staging.divorce_rate
type: duckdb.sql
connection: main_db
depends:
  - load.divorce_rate
materialization:
  type: table
@bruin */
SELECT country, year, divorce_rate
FROM load.divorce_rate