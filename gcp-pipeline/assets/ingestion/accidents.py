"""@bruin
name: ingestion.accidents
type: python
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from utils import ingest_eurostat

ingest_eurostat("hsw_n2_01", "accidents")
