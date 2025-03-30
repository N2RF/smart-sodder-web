import gleam/dynamic/decode
import gleam/option.{type Option}
import pog

/// A row you get from running the `get_lab_by_name` query
/// defined in `./src/sql/get_lab_by_name.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetLabByNameRow {
  GetLabByNameRow(id: Int, lab_name: String, number_of_boards: Int)
}

/// Runs the `get_lab_by_name` query
/// defined in `./src/sql/get_lab_by_name.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_lab_by_name(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use lab_name <- decode.field(1, decode.string)
    use number_of_boards <- decode.field(2, decode.int)
    decode.success(GetLabByNameRow(id:, lab_name:, number_of_boards:))
  }

  "SELECT
    *
FROM
    labs
where
    lab_name=$1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `new_device` query
/// defined in `./src/sql/new_device.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type NewDeviceRow {
  NewDeviceRow(
    mac_address: String,
    number: Option(Int),
    lab_id: Option(Int),
    status: Option(Bool),
    wats_per_hour: Option(Int),
    hours_on: Option(Int),
    minutes_on: Option(Int),
  )
}

/// Runs the `new_device` query
/// defined in `./src/sql/new_device.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn new_device(db, arg_1, arg_2) {
  let decoder = {
    use mac_address <- decode.field(0, decode.string)
    use number <- decode.field(1, decode.optional(decode.int))
    use lab_id <- decode.field(2, decode.optional(decode.int))
    use status <- decode.field(3, decode.optional(decode.bool))
    use wats_per_hour <- decode.field(4, decode.optional(decode.int))
    use hours_on <- decode.field(5, decode.optional(decode.int))
    use minutes_on <- decode.field(6, decode.optional(decode.int))
    decode.success(
      NewDeviceRow(
        mac_address:,
        number:,
        lab_id:,
        status:,
        wats_per_hour:,
        hours_on:,
        minutes_on:,
      ),
    )
  }

  "insert into devices (
    lab_id,
    status,
    wats_per_hour,
    hours_on,
    minutes_on
) VALUES ($1,False,$2,0,0) RETURNING *
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `new_lab` query
/// defined in `./src/sql/new_lab.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type NewLabRow {
  NewLabRow(id: Int, lab_name: String, number_of_boards: Int)
}

/// Runs the `new_lab` query
/// defined in `./src/sql/new_lab.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn new_lab(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use lab_name <- decode.field(1, decode.string)
    use number_of_boards <- decode.field(2, decode.int)
    decode.success(NewLabRow(id:, lab_name:, number_of_boards:))
  }

  "insert into labs (
    lab_name,
    number_of_boards
) VALUES ($1,0) RETURNING *
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_device_history` query
/// defined in `./src/sql/get_device_history.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetDeviceHistoryRow {
  GetDeviceHistoryRow(
    id: Int,
    mac_address: Option(String),
    status: Option(Bool),
    time: Option(String),
  )
}

/// Runs the `get_device_history` query
/// defined in `./src/sql/get_device_history.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_device_history(db, arg_1) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use mac_address <- decode.field(1, decode.optional(decode.string))
    use status <- decode.field(2, decode.optional(decode.bool))
    use time <- decode.field(3, decode.optional(decode.string))
    decode.success(GetDeviceHistoryRow(id:, mac_address:, status:, time:))
  }

  "SELECT
    *
FROM
    history
where
    mac_address=$1;
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `new_history` query
/// defined in `./src/sql/new_history.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type NewHistoryRow {
  NewHistoryRow(
    id: Int,
    mac_address: Option(String),
    status: Option(Bool),
    time: Option(String),
  )
}

/// Runs the `new_history` query
/// defined in `./src/sql/new_history.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn new_history(db, arg_1, arg_2, arg_3) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use mac_address <- decode.field(1, decode.optional(decode.string))
    use status <- decode.field(2, decode.optional(decode.bool))
    use time <- decode.field(3, decode.optional(decode.string))
    decode.success(NewHistoryRow(id:, mac_address:, status:, time:))
  }

  "insert into history (
    mac_address,
    Status,
    Time
) VALUES ($1,$2,$3) RETURNING *
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.bool(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_labs` query
/// defined in `./src/sql/get_labs.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetLabsRow {
  GetLabsRow(id: Int, lab_name: String, number_of_boards: Int)
}

/// Runs the `get_labs` query
/// defined in `./src/sql/get_labs.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_labs(db) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use lab_name <- decode.field(1, decode.string)
    use number_of_boards <- decode.field(2, decode.int)
    decode.success(GetLabsRow(id:, lab_name:, number_of_boards:))
  }

  "SELECT
    *
FROM
    labs;
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_devices_in_lab` query
/// defined in `./src/sql/get_devices_in_lab.sql`.
///
/// > 🐿️ This type definition was generated automatically using v3.0.1 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetDevicesInLabRow {
  GetDevicesInLabRow(
    mac_address: String,
    number: Option(Int),
    lab_id: Option(Int),
    status: Option(Bool),
    wats_per_hour: Option(Int),
    hours_on: Option(Int),
    minutes_on: Option(Int),
  )
}

/// Runs the `get_devices_in_lab` query
/// defined in `./src/sql/get_devices_in_lab.sql`.
///
/// > 🐿️ This function was generated automatically using v3.0.1 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_devices_in_lab(db, arg_1) {
  let decoder = {
    use mac_address <- decode.field(0, decode.string)
    use number <- decode.field(1, decode.optional(decode.int))
    use lab_id <- decode.field(2, decode.optional(decode.int))
    use status <- decode.field(3, decode.optional(decode.bool))
    use wats_per_hour <- decode.field(4, decode.optional(decode.int))
    use hours_on <- decode.field(5, decode.optional(decode.int))
    use minutes_on <- decode.field(6, decode.optional(decode.int))
    decode.success(
      GetDevicesInLabRow(
        mac_address:,
        number:,
        lab_id:,
        status:,
        wats_per_hour:,
        hours_on:,
        minutes_on:,
      ),
    )
  }

  "SELECT
    *
FROM
    devices
where
    lab_id=$1;
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}
