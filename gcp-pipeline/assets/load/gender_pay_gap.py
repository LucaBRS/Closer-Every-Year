"""@bruin
name: load.gender_pay_gap
type: python
connection: gcp_conn
depends:
  - ingestion.gender_pay_gap
materialization:
  type: table
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))

import pandas as pd
from utils import GCS_BUCKET, gcs_storage_options, validate_df


def materialize(**kwargs):
    df = pd.read_parquet(f"{GCS_BUCKET}/gender_pay_gap.parquet", storage_options=gcs_storage_options())
    validate_df(df, "gender_pay_gap")
    exclude = ['freq', 'unit', 'nace_r2', 'country']
    id_cols = [c for c in df.columns if c in exclude]
    year_cols = [c for c in df.columns if c not in id_cols]
    df = df.melt(id_vars=id_cols, value_vars=year_cols, var_name='year', value_name='gender_pay_gap')
    df = df[df['nace_r2'] == 'B-S_X_O']  # total economy
    df = df.dropna(subset=['gender_pay_gap'])
    df['year'] = df['year'].str.replace('_', '', regex=False).astype(int)
    return df[['country', 'year', 'gender_pay_gap']].reset_index(drop=True)
