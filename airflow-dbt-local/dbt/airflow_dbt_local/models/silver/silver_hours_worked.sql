with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'hours_worked', ['country', 'sex', 'age', 'nace_r2', 'wstatus', 'worktime'], ['freq', 'unit'], 'hours_worked') }}
    ),
    unpivoted_clean_cte as (
        select
            country,
            sex,
            year,
            hours_worked
        from unpivoted_cte
        where sex in ('M', 'F')
            and age = 'Y_GE15'
            and nace_r2 = 'TOTAL'
            and wstatus = 'EMP'
            and worktime = 'TOTAL'
            and length(country) <= 2
    )

select
    country,
    year,
    sum(case when sex = 'M' then hours_worked end) as hours_worked_m,
    sum(case when sex = 'F' then hours_worked end) as hours_worked_f
from unpivoted_clean_cte
group by country, year
