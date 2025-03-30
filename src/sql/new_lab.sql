insert into labs (
    lab_name,
    number_of_boards
) VALUES ($1,0) RETURNING *
