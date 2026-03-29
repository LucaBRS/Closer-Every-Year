"""@bruin
name: load.marriage_rate
type: python
connection: main_db
depends:
  - ingestion.marriage_rate
materialization:
  type: table
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import pandas as pd
from utils import validate_df

DATA_PATH = "/workspace/data/datalake"

def materialize(**kwargs):
    df = pd.read_parquet(f"{DATA_PATH}/marriage_rate.parquet")
    validate_df(df, "marriage_rate")
    exclude = ['freq', 'indic_de', 'country']
    id_cols = [c for c in df.columns if c in exclude]
    year_cols = [c for c in df.columns if c not in id_cols]
    df = df.melt(id_vars=id_cols, value_vars=year_cols, var_name='year', value_name='marriage_rate')
    df = df.dropna(subset=['marriage_rate'])
    df['year'] = df['year'].str.replace('_', '', regex=False).astype(int)
    return df[['country', 'year', 'marriage_rate']].reset_index(drop=True)
