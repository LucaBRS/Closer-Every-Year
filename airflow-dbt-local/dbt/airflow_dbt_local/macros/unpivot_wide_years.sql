{% macro unpivot_wide_years(source_name, table_name, keep_columns, drop_columns=[], value_column='value') %}
    {% set cols = adapter.get_columns_in_relation(source(source_name, table_name)) %}
    {% set non_year_columns = keep_columns + drop_columns %}
    {% set year_cols = cols | map(attribute='name') | reject('in', non_year_columns) | list %}

    {% for col in year_cols %}
        select
            {% for kc in keep_columns %}{{ kc }},{% endfor %}
            cast(replace('{{ col }}', '_', '') as integer) as year,
            "{{ col }}" as {{ value_column }}
        from {{ source(source_name, table_name) }}
        {% if not loop.last %}union all{% endif %}
    {% endfor %}
{% endmacro %}
