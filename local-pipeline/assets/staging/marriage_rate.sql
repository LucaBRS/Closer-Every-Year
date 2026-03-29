/* @bruin
name: staging.marriage_rate
type: duckdb.sql
connection: main_db
depends:
  - load.marriage_rate
materialization:
  type: table
@bruin */
SELECT country, year, marriage_rate
FROM load.marriage_rate