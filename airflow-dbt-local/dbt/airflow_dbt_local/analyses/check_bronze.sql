select *
from {{ source('bronze', 'divorce_rate') }}
