with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'employed', ['country', 'sex', 'age', 'nace_r2'], ['freq', 'unit'], 'employed') }}
    ),
    unpivoted_clean_cte as (
        select
            country,
            sex,
            year,
            employed
        from unpivoted_cte
        where sex in ('M', 'F')
            and age = 'Y_GE15'
            and nace_r2 = 'TOTAL'
            and length(country) <= 2
    )

select
    country,
    year,
    sum(case when sex = 'M' then employed end) as employed_m,
    sum(case when sex = 'F' then employed end) as employed_f
from unpivoted_clean_cte
group by country, year
