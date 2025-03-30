insert into history (
    mac_address,
    Status,
    Time
) VALUES ($1,$2,$3) RETURNING *
