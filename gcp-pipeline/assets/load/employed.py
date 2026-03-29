"""@bruin
name: load.employed
type: python
connection: gcp_conn
depends:
  - ingestion.employed
materialization:
  type: table
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))

import pandas as pd
from utils import GCS_BUCKET, gcs_storage_options, validate_df


def materialize(**kwargs):
    df = pd.read_parquet(f"{GCS_BUCKET}/employed.parquet", storage_options=gcs_storage_options())
    validate_df(df, "employed")
    # TODO: verify age and nace_r2 values for total working-age population
    exclude = ['freq', 'unit', 'sex', 'age', 'nace_r2', 'country']
    id_cols = [c for c in df.columns if c in exclude]
    year_cols = [c for c in df.columns if c not in id_cols]
    df = df.melt(id_vars=id_cols, value_vars=year_cols, var_name='year', value_name='employed')
    df = df[df['sex'].isin(['M', 'F'])]
    df = df[df['age'] == 'Y15-74']
    df = df[df['nace_r2'] == 'TOTAL']
    df = df.dropna(subset=['employed'])
    df['year'] = df['year'].str.replace('_', '', regex=False).astype(int)
    return df[['country', 'year', 'sex', 'employed']].reset_index(drop=True)
