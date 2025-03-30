insert into devices (
    mac_address,
    lab_id,
    status,
    wats_per_hour,
    hours_on,
    minutes_on
) VALUES ($1,$2,False,$3,0,0) RETURNING *
