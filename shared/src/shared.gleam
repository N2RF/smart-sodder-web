import birl
import gleam/json
import gleam/dynamic/decode

//todo refgactor to be usfle
pub type Lab {
  Lab(
    id: Int,
    bench_name:String,
    number_of_boards:Int,
  )
  LabUseful(
    id: Int,
    bench_name:String,
    number_of_boards:Int,
    devices:List(Device)
  )
}

pub fn encode_lab(lab: Lab) -> json.Json {
  case lab {
    Lab(..) -> json.object([
      #("type", json.string("lab")),
      #("id", json.int(lab.id)),
      #("bench_name", json.string(lab.bench_name)),
      #("number_of_boards", json.int(lab.number_of_boards)),
    ])
    LabUseful(..) -> json.object([
      #("type", json.string("lab_useful")),
      #("id", json.int(lab.id)),
      #("bench_name", json.string(lab.bench_name)),
      #("number_of_boards", json.int(lab.number_of_boards)),
      #("devices", json.array(lab.devices, encode_device)),
    ])
  }
}

pub fn lab_decoder() -> decode.Decoder(Lab) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "lab" -> {
      use id <- decode.field("id", decode.int)
      use bench_name <- decode.field("bench_name", decode.string)
      use number_of_boards <- decode.field("number_of_boards", decode.int)
      decode.success(Lab(id:, bench_name:, number_of_boards:))
    }
    "lab_useful" -> {
      use id <- decode.field("id", decode.int)
      use bench_name <- decode.field("bench_name", decode.string)
      use number_of_boards <- decode.field("number_of_boards", decode.int)
      use devices <- decode.field("devices", decode.list(device_decoder()))
      decode.success(LabUseful(id:, bench_name:, number_of_boards:, devices:))
    }
    _ -> decode.failure(Lab(-1,"no name",0), "Lab")
  }
}





pub type Device {
  Device(
    mac_address:String,
    bench_id:Int,
    number:Int,
    status:Bool,
    wats_per_hour:Int,
    hours_on:Int,
    minutes_on:Int,
  )
}

pub fn encode_device(device: Device) -> json.Json {
  json.object([
    #("mac_address", json.string(device.mac_address)),
    #("bench_id", json.int(device.bench_id)),
    #("number", json.int(device.number)),
    #("status", json.bool(device.status)),
    #("wats_per_hour", json.int(device.wats_per_hour)),
    #("hours_on", json.int(device.hours_on)),
    #("minutes_on", json.int(device.minutes_on)),
  ])
}

pub fn device_decoder() -> decode.Decoder(Device) {
  use mac_address <- decode.field("mac_address", decode.string)
  use bench_id <- decode.field("bench_id", decode.int)
  use number <- decode.field("number", decode.int)
  use status <- decode.field("status", decode.bool)
  use wats_per_hour <- decode.field("wats_per_hour", decode.int)
  use hours_on <- decode.field("hours_on", decode.int)
  use minutes_on <- decode.field("minutes_on", decode.int)
  decode.success(Device(mac_address:, bench_id:, number:, status:, wats_per_hour:, hours_on:, minutes_on:))
}




pub type History {
  History(
    id:Int,
    device_id:Int,
    status:Bool,
    time:birl.Time,
  )
}

pub fn encode_history(history: History) -> json.Json {
  json.object([
    #("id", json.int(history.id)),
    #("device_id", json.int(history.device_id)),
    #("status", json.bool(history.status)),
    #("time",  json.string(birl.to_naive_time_string(history.time))),
  ])
}

pub fn history_decoder() -> decode.Decoder(History) {
  use id <- decode.field("id", decode.int)
  use device_id <- decode.field("device_id", decode.int)
  use status <- decode.field("status", decode.bool)
  use time <- decode.field("time", decode.string)
  case birl.from_naive(time) {
    Ok(time) ->   decode.success(History(id:, device_id:, status:,time:time ))
    Error(_) -> decode.failure(History(id:, device_id:, status:,time:birl.now() ),"history")
  }
}
