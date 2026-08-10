with
    unpivoted_cte as (
        {{ unpivot_wide_years('source', 'age_at_marriage', ['country','indic_de'], ['freq'], 'age_at_marriage') }}
    )




select
    country,
    year,
    AVG(CASE WHEN indic_de = 'FAGEMAR1' THEN age_at_marriage END) AS age_at_marriage_f,
    AVG(CASE WHEN indic_de = 'MAGEMAR1' THEN age_at_marriage END) AS age_at_marriage_m

from unpivoted_cte
where length(country) <= 2

group by country, year