{% set cols = adapter.get_columns_in_relation(source("source", "accidents")) %}
{% set exclude = ["freq", "unit", "nace_r2", "sex", "country"] %}
{% set year_cols = cols | map(attribute="name") | reject("in", exclude) | list %}

with
    unpivoted_cte as (
        {% for col in year_cols %}
            select country, sex, nace_r2, '{{ col }}' as year, "{{ col }}" as accidents
            from {{ source("source", "accidents") }}
            {% if not loop.last %}
                union all
            {% endif %}
        {% endfor %}
    ),
    unpivoted_clean_cte as (
        select
            country,
            sex,
            nace_r2,
            cast(replace(year, '_', '') as integer) as year,
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

