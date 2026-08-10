select *
from {{ source('source', 'divorce_rate') }} LIMIT 10;

select *
from {{ source('source', 'marriage_rate') }} LIMIT 10;

select *
from {{ source('source', 'age_at_marriage') }} LIMIT 10;

select *
from {{ source('source', 'accidents') }} LIMIT 10;

select *
from {{ source('source', 'employed') }} LIMIT 10;

select *
from {{ source('source', 'gender_pay_gap') }} LIMIT 10;

select *
from {{ source('source', 'hours_worked') }} LIMIT 10;


select
    country,
    sex,
    '2024' as year,
    "2024" as accidents
from "dev"."bronze"."accidents" limit 10;