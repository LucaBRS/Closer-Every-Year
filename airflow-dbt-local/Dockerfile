FROM apache/airflow:3.3.0

# DONE_WHY: the base Airflow image has no data-engineering libraries installed.
# The DAG tasks call the Eurostat API (eurostat), read/write Parquet (pandas, pyarrow),
# write to DuckDB (duckdb), and now also run dbt itself (dbt-core, dbt-duckdb) as the
# third pipeline step — none of that works unless it's baked into the image the workers
# actually run.
RUN pip install --no-cache-dir eurostat pandas pyarrow duckdb dbt-core dbt-duckdb
