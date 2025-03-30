insert into devices (
    lab_id,
    status,
    wats_per_hour,
    hours_on,
    minutes_on
) VALUES ($1,False,$2,0,0) RETURNING *
