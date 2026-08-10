with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'marriage_rate', ['country'], ['freq', 'indic_de'], 'marriage_rate') }}
    )

select
    country,
    year,
    marriage_rate
from unpivoted_cte
where length(country) <= 2
