"""@bruin
name: ingestion.gender_pay_gap
type: python
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from utils import ingest_eurostat

ingest_eurostat("sdg_05_20", "gender_pay_gap")
