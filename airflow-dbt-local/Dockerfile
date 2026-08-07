FROM apache/airflow:3.3.0

# DONE_WHY: the base Airflow image has no data-engineering libraries installed.
# The DAG tasks call the Eurostat API (eurostat), read/write Parquet (pandas, pyarrow),
# and write to DuckDB (duckdb) — none of that works unless it's baked into the image
# the workers actually run.
RUN pip install --no-cache-dir eurostat pandas pyarrow duckdb
