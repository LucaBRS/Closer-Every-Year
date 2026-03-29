/* @bruin
name: staging.age_at_marriage
type: bq.sql
connection: gcp_conn
depends:
  - load.age_at_marriage
materialization:
  type: table
  strategy: merge
columns:
  - name: country
    primary_key: true
  - name: year
    primary_key: true
  - name: age_at_marriage_f
  - name: age_at_marriage_m
@bruin */

SELECT
a.country,
a.year,
    AVG(CASE WHEN a.indic_de = 'FAGEMAR1' THEN a.age_at_marriage END) AS age_at_marriage_f,
    AVG(CASE WHEN a.indic_de = 'MAGEMAR1' THEN a.age_at_marriage END) AS age_at_marriage_m
FROM load.age_at_marriage as a
GROUP BY a.country, a.year
