import json
import os

import pandas as pd
from google.cloud import bigquery
from google.oauth2 import service_account

GCS_BUCKET = os.environ["GCS_BUCKET"]
GCP_PROJECT_ID = os.environ["GCP_PROJECT_ID"]


def validate_df(df: pd.DataFrame, name: str) -> None:
    if df is None or df.empty:
        raise ValueError(f"DataFrame for '{name}' is empty or None — check ingestion or filter values.")


def gcs_storage_options() -> dict:
    return {"token": json.loads(os.environ["GOOGLE_CREDENTIALS"])}


def write_to_bq(df: pd.DataFrame, table: str) -> None:
    credentials = service_account.Credentials.from_service_account_info(
        json.loads(os.environ["GOOGLE_CREDENTIALS"])
    )
    client = bigquery.Client(project=GCP_PROJECT_ID, credentials=credentials)
    dataset = bigquery.Dataset(f"{GCP_PROJECT_ID}.load")
    dataset.location = "EU"
    client.create_dataset(dataset, exists_ok=True)
    gcs_uri = f"{GCS_BUCKET}/_tmp_{table}.parquet"
    df.to_parquet(gcs_uri, index=False, storage_options=gcs_storage_options())
    job_config = bigquery.LoadJobConfig(
        write_disposition="WRITE_TRUNCATE",
        source_format=bigquery.SourceFormat.PARQUET,
    )
    client.load_table_from_uri(gcs_uri, f"load.{table}", job_config=job_config).result()
    print(f"Written {len(df)} rows to load.{table}")
