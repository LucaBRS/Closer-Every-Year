"""@bruin
name: ingestion.divorce_rate
type: python
@bruin"""

import sys, os
sys.path.insert(0, os.path.dirname(__file__))
from utils import ingest_eurostat

ingest_eurostat("tps00216", "divorce_rate")
