select *
from {{ ref('silver_accidents') }} LIMIT 10;
