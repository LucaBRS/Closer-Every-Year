with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'divorce_rate', ['country'], ['freq', 'indic_de'], 'divorce_rate') }}
    )

select
    country,
    year,
    divorce_rate
from unpivoted_cte
where length(country) <= 2