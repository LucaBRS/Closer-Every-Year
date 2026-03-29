/* @bruin
name: staging.employed
type: bq.sql
connection: gcp_conn
depends:
  - load.employed
materialization:
  type: table
  strategy: merge
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: employed_m
  - name: employed_f
@bruin */

SELECT
    e.country,
    e.year,
    AVG(CASE WHEN e.sex = 'M' THEN e.employed END) AS employed_m,
    AVG(CASE WHEN e.sex = 'F' THEN e.employed END) AS employed_f
FROM load.employed AS e
GROUP BY e.country, e.year
