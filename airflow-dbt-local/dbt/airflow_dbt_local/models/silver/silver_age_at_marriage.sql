with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'age_at_marriage', ['country'], ['freq', 'indic_de'], 'age_at_marriage') }}
    )

select
    country,
    year,
    age_at_marriage
from unpivoted_cte
where length(country) <= 2
