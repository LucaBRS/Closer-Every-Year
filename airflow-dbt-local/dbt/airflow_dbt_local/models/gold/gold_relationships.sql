SELECT
    m.country,
    m.year,
    m.marriage_rate,
    d.divorce_rate,
    a.age_at_marriage_f,
    a.age_at_marriage_m,
    iq.gender_pay_gap
FROM {{ref('silver_marriage_rate')}} m
LEFT JOIN {{ref('silver_divorce_rate')}} d
    ON m.country = d.country AND m.year = d.year
LEFT JOIN {{ref('silver_age_at_marriage')}} a
    ON m.country = a.country AND m.year = a.year
LEFT JOIN {{ref('silver_gender_pay_gap')}} iq
    ON m.country = iq.country AND m.year = iq.year


order by m.country, m.year
