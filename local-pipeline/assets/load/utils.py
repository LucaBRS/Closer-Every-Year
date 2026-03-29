import pandas as pd


def validate_df(df: pd.DataFrame, name: str) -> None:
    if df is None or df.empty:
        raise ValueError(f"DataFrame for '{name}' is empty or None — check ingestion or filter values.")
