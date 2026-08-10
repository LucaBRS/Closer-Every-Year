from datetime import datetime

from airflow.sdk import dag, task

DATA_PATH = "/opt/airflow/data/datalake"
DUCKDB_PATH = "/opt/airflow/data/dev.duckdb"

# output table name -> Eurostat dataset code
DATASETS = {
    "divorce_rate": "tps00216",
    "marriage_rate": "tps00206",
    "age_at_marriage": "tps00014",
    "accidents": "hsw_n2_01",
    "employed": "lfsa_eegan2",
    "gender_pay_gap": "sdg_05_20",
    "hours_worked": "lfsa_ewhan2",
}


@dag(schedule=None, start_date=datetime(2026, 1, 1), catchup=False)
def bronze_ingestion():

    @task
    def download_parquet(output_name: str, dataset_code: str) -> str:
        import os
        import time

        import eurostat

        df = None
        for attempt in range(1, 4):
            df = eurostat.get_data_df(dataset_code)
            if df is not None and not df.empty:
                break
            print(f"Attempt {attempt}/3: empty response for '{dataset_code}', retrying in 10s...")
            time.sleep(10)
        if df is None or df.empty:
            raise ValueError(f"Eurostat returned no data for '{dataset_code}'")

        df = df.rename(columns={"geo\\TIME_PERIOD": "country"})
        os.makedirs(DATA_PATH, exist_ok=True)
        df.to_parquet(f"{DATA_PATH}/{output_name}.parquet", index=False)
        return output_name

    @task
    def load_to_duckdb(output_name: str) -> None:
        import duckdb

        con = duckdb.connect(DUCKDB_PATH)
        con.sql("CREATE SCHEMA IF NOT EXISTS bronze")
        con.sql(f"""
            CREATE OR REPLACE TABLE bronze.{output_name} AS
            SELECT * FROM read_parquet('{DATA_PATH}/{output_name}.parquet')
        """)

    @task(pool="duckdb_writer")
    def dbt_build() -> None:
        import subprocess

        # DONE_WHY: dbt itself needs a DuckDB write connection (to build silver/gold
        # tables) — it's pinned to the same duckdb_writer pool as load_to_duckdb so it
        # never races a still-running load task for the file lock.
        # DONE_WHY: --no-partial-parse avoids dbt reusing target/partial_parse.msgpack —
        # that cache is also written when you run dbt from the host (VS Code extension,
        # terminal), and its file keys don't reliably match what the Linux container sees
        # on the same mounted folder, causing spurious "KeyError: ...macros/....sql".
        # DONE_WHY: profiles.yml's duckdb path ("../../data/dev.duckdb") is relative to the
        # process's cwd, not to --project-dir. Without cwd= here, it inherits Airflow's
        # default cwd (/opt/airflow) and resolves to the wrong place ("/data/dev.duckdb").
        result = subprocess.run(
            [
                "dbt",
                "--no-partial-parse",
                "build",
                "--project-dir",
                "/opt/airflow/dbt/airflow_dbt_local",
                "--profiles-dir",
                "/opt/airflow/dbt/airflow_dbt_local",
            ],
            cwd="/opt/airflow/dbt/airflow_dbt_local",
            capture_output=True,
            text=True,
        )
        print(result.stdout)
        print(result.stderr)
        if result.returncode != 0:
            raise RuntimeError("dbt build failed")

    # DONE_WHY: The DAG tasks call the Eurostat API (eurostat), read/write Parquet (pandas, pyarrow),
    # and write to DuckDB (duckdb)
    #  this for will create 7 different pipelines, each with its own tasks.
    #  The tasks are independent of each other, and can run in parallel.
    load_tasks = []
    for output_name, dataset_code in DATASETS.items():
        parquet_name = download_parquet.override(task_id=f"download_{output_name}")(
            output_name, dataset_code
        )
        # DONE_WHY: DuckDB allows only one writer connection at a time on a single file.
        # Running load_* tasks in parallel causes lock conflicts, so they're pinned to a
        # 1-slot pool to force them to run one at a time while downloads stay parallel.
        # this `docker compose run --rm airflow-cli pools set duckdb_writer 1 "serializes writes to dev.duckdb"` will create the pool of 1 slot
        # this `docker compose run --rm airflow-cli pools list` will list the pools
        load_task = load_to_duckdb.override(task_id=f"load_{output_name}", pool="duckdb_writer")(
            parquet_name
        )
        load_tasks.append(load_task)

    # DONE_WHY: dbt_build reads bronze.* tables that every load_* task writes — it must
    # wait for ALL of them to finish, not just one, hence the fan-in on the whole list.
    load_tasks >> dbt_build()


bronze_ingestion()
