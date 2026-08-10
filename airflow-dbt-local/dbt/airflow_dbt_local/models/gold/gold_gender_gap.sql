SELECT
    h.country,
    h.year,
    h.hours_worked_m,
    h.hours_worked_f,
    h.hours_worked_delta,
    g.gender_pay_gap,
    ac.accidents_m,
    ac.accidents_f,
    e.employed_m,
    e.employed_f
FROM {{ref('silver_hours_worked')}} h
LEFT JOIN {{ref('silver_gender_pay_gap')}} g
    ON h.country = g.country AND h.year = g.year
LEFT JOIN {{ref('silver_accidents')}} ac
    ON h.country = ac.country AND h.year = ac.year
LEFT JOIN {{ref('silver_employed')}} e
    ON h.country = e.country AND h.year = e.year
ORDER BY h.country, h.year