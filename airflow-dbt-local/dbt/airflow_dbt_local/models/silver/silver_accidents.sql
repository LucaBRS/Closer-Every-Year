with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'accidents', ['country', 'sex', 'nace_r2'], ['freq', 'unit'], 'accidents') }}
    ),
    unpivoted_clean_cte as (
        select
            country,
            sex,
            nace_r2,
            year,
            accidents
        from unpivoted_cte
        where sex in ('M', 'F') and nace_r2 = 'TOTAL' and accidents is not null
    )

select
    country,
    year,
    sum(case when sex = 'M' then accidents end) as accidents_m,
    sum(case when sex = 'F' then accidents end) as accidents_f
from unpivoted_clean_cte
where length(country) <= 2
group by country, year

