"""@bruin
name: load.hours_worked
type: python
connection: main_db
depends:
  - ingestion.hours_worked
materialization:
  type: table
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import pandas as pd
from utils import validate_df

DATA_PATH = "/workspace/data/datalake"


def materialize(**kwargs):
    df = pd.read_parquet(f"{DATA_PATH}/hours_worked.parquet")
    validate_df(df, "hours_worked")
    exclude = ['freq', 'nace_r2', 'wstatus', 'worktime', 'age', 'sex', 'unit', 'country']
    id_cols = [c for c in df.columns if c in exclude]
    year_cols = [c for c in df.columns if c not in id_cols]
    df = df.melt(id_vars=id_cols, value_vars=year_cols, var_name='year', value_name='hours_worked')
    df = df[df['sex'].isin(['M', 'F'])]

    df = df.dropna(subset=['hours_worked'])
    df['year'] = df['year'].str.replace('_', '', regex=False).astype(int)
    return df[['country', 'year', 'sex', 'hours_worked']].reset_index(drop=True)
