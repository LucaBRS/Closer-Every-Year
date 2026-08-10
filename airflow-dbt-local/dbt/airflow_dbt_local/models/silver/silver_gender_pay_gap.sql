with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'gender_pay_gap', ['country'], ['freq', 'unit', 'nace_r2'], 'gender_pay_gap') }}
    )

select
    country,
    year,
    gender_pay_gap
from unpivoted_cte
where length(country) <= 2
