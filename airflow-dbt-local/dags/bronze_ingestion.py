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


    # DONE_WHY: The DAG tasks call the Eurostat API (eurostat), read/write Parquet (pandas, pyarrow),
    # and write to DuckDB (duckdb)
    #  this for will create 7 different pipelines, each with its own tasks.
    #  The tasks are independent of each other, and can run in parallel.
    for output_name, dataset_code in DATASETS.items():
        parquet_name = download_parquet.override(task_id=f"download_{output_name}")(
            output_name, dataset_code
        )
        # DONE_WHY: DuckDB allows only one writer connection at a time on a single file.
        # Running load_* tasks in parallel causes lock conflicts, so they're pinned to a
        # 1-slot pool to force them to run one at a time while downloads stay parallel.
        load_to_duckdb.override(task_id=f"load_{output_name}", pool="duckdb_writer")(
            parquet_name
        )




bronze_ingestion()
