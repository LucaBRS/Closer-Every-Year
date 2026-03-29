"""@bruin
name: ingestion.age_at_marriage
type: python

@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from utils import ingest_eurostat

ingest_eurostat("tps00014", "age_at_marriage")
