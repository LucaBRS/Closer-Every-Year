import eurostat
import json
import os
import time

GCS_BUCKET = os.environ["GCS_BUCKET"]

MAX_RETRIES = 3
RETRY_WAIT = 10  # seconds


def ingest_eurostat(dataset_code: str, output_name: str) -> None:
    print(f"Downloading {dataset_code} from Eurostat...")
    df = None
    for attempt in range(1, MAX_RETRIES + 1):
        df = eurostat.get_data_df(dataset_code)
        if df is not None and not df.empty:
            break
        print(f"Attempt {attempt}/{MAX_RETRIES}: Eurostat returned None or empty for '{dataset_code}', retrying in {RETRY_WAIT}s...")
        time.sleep(RETRY_WAIT)
    if df is None or df.empty:
        raise ValueError(f"Eurostat returned None or empty dataset for '{dataset_code}' after {MAX_RETRIES} attempts.")
    df = df.rename(columns={"geo\\TIME_PERIOD": "country"})
    print(f"Downloaded {len(df)} rows, saving to GCS...")
    credentials = json.loads(os.environ["GOOGLE_CREDENTIALS"])
    df.to_parquet(
        f"{GCS_BUCKET}/{output_name}.parquet",
        index=False,
        storage_options={"token": credentials},
    )
    print(f"Saved {output_name}.parquet to GCS.")
