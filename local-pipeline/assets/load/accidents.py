"""@bruin
name: load.accidents
type: python
connection: main_db
depends:
  - ingestion.accidents
materialization:
  type: table
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import pandas as pd
from utils import validate_df

DATA_PATH = "/workspace/data/datalake"


def materialize(**kwargs):
    df = pd.read_parquet(f"{DATA_PATH}/accidents.parquet")
    validate_df(df, "accidents")
    exclude = ['freq', 'unit', 'nace_r2', 'sex', 'country']
    id_cols = [c for c in df.columns if c in exclude]
    year_cols = [c for c in df.columns if c not in id_cols]
    df = df.melt(id_vars=id_cols, value_vars=year_cols, var_name='year', value_name='accidents')
    df = df[df['sex'].isin(['M', 'F'])]
    df = df[df['nace_r2'] == 'TOTAL']
    df = df.dropna(subset=['accidents'])
    df['year'] = df['year'].str.replace('_', '', regex=False).astype(int)
    return df[['country', 'year', 'sex', 'accidents']].reset_index(drop=True)
