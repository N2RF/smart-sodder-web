import gleam/list
import pog
import sql
import wisp/wisp_mist
import gleam/result
import gleam/http
import birl
import gleam/json
import gleam/dynamic/decode
import lustre/element/html
import lustre/attribute
import gleam/bytes_tree
import gleam/io
import gleam/erlang/process
import gleam/option.{None, Some}
import mist.{type Connection, type ResponseData}
import lustre/element
import wisp.{type Request, type Response}



type Lab {
  Lab(
    id: Int,
    bench_name:String,
    number_of_boards:Int,
  )
}

fn encode_lab(lab: Lab) -> json.Json {
  json.object([
    #("bench_name", json.string(lab.bench_name)),
    #("number_of_boards", json.int(lab.number_of_boards)),
    #("id", json.int(lab.id)),
  ])
}

fn lab_decoder() -> decode.Decoder(Lab) {
  use bench_name <- decode.field("bench_name", decode.string)
  use number_of_boards <- decode.field("number_of_boards", decode.int)
  use id <- decode.field("id", decode.int)
  decode.success(Lab(bench_name:, number_of_boards:, id:))
}




type Device {
  Device(
    id:Int,
    bench_id:Int,
    status:Bool,
    wats_per_hour:Int,
    hours_on:Int,
    minutes_on:Int,
  )
}

fn encode_device(device: Device) -> json.Json {
  json.object([
    #("id", json.int(device.id)),
    #("bench_id", json.int(device.bench_id)),
    #("status", json.bool(device.status)),
    #("wats_per_hour", json.int(device.wats_per_hour)),
    #("hours_on", json.int(device.hours_on)),
    #("minutes_on", json.int(device.minutes_on)),
  ])
}

fn device_decoder() -> decode.Decoder(Device) {
  use id <- decode.field("id", decode.int)
  use bench_id <- decode.field("bench_id", decode.int)
  use status <- decode.field("status", decode.bool)
  use wats_per_hour <- decode.field("wats_per_hour", decode.int)
  use hours_on <- decode.field("hours_on", decode.int)
  use minutes_on <- decode.field("minutes_on", decode.int)
  decode.success(Device(id:, bench_id:, status:, wats_per_hour:, hours_on:, minutes_on:))
}
type History {
  History(
    id:Int,
    device_id:Int,
    status:Bool,
    time:birl.Time,
  )
}

fn encode_history(history: History) -> json.Json {
  json.object([
    #("id", json.int(history.id)),
    #("device_id", json.int(history.device_id)),
    #("status", json.bool(history.status)),
    #("time",  json.string(birl.to_naive_time_string(history.time))),
  ])
}

fn history_decoder() -> decode.Decoder(History) {
  use id <- decode.field("id", decode.int)
  use device_id <- decode.field("device_id", decode.int)
  use status <- decode.field("status", decode.bool)
  use time <- decode.field("time", decode.string)
  case birl.from_naive(time) {
    Ok(time) ->   decode.success(History(id:, device_id:, status:,time:time ))
    Error(_) -> decode.failure(History(id:, device_id:, status:,time:birl.now() ),"history")
  }
}



pub fn main() {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let db =
    pog.default_config()
    |> pog.host("localhost")
    |> pog.database("my_database")
    |> pog.pool_size(15)
    |> pog.connect
  let handler = handler(_,db)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
}


fn handler(req: Request,conn) -> Response {
  use <- wisp.log_request(req)
  case wisp.path_segments(req) {
    ["bench"] -> bench_handler(req,conn)
    ["device"] -> device_handler(req,conn)
    _ -> not_found()
  }
}

fn recover_or_return(res:Result(a,b),callback: fn(b) -> a) {
  case res {
    Error(b) -> callback(b)
    Ok(a) -> a
  }
}

type NewLabRequest{
  NewLabRequest(
    name:String
  )
}

fn new_lab_request_decoder() -> decode.Decoder(NewLabRequest) {
  use name <- decode.field("name", decode.string)
  decode.success(NewLabRequest(name:))
}

fn bench_handler(req: Request,conn) {
  case req.method {
    http.Delete -> not_found()
    http.Get -> not_found()
    http.Post -> {
      use json <- wisp.require_json(req)
      use <- wisp.rescue_crashes
      let res = {
        use bench <- result.try(result.replace_error(decode.run(json,new_lab_request_decoder()),"you sent us bad and evil json "))
        let assert Ok(row) = sql.new_lab(conn,bench.name)
        let assert Ok(first) = list.first(row.rows)
        Lab(first.id,first.lab_name,first.number_of_boards)
        |> encode_lab
        |> json.to_string_tree
        |> wisp.json_response(200)
        |> Ok
      }
      use err <- recover_or_return(res) // this returns the final result or recovers with the bellow
      error_page(err)
    }
    _ -> not_found()
  }

}

type NewDeviceRequest{
  NewDeviceRequest(
    bench_id:Int,
    wats_per_hour:Int,
  )
}

fn new_device_request_decoder() -> decode.Decoder(NewDeviceRequest) {
  use bench_id <- decode.field("bench_id", decode.int)
  use wats_per_hour <- decode.field("wats_per_hour", decode.int)
  decode.success(NewDeviceRequest(bench_id:, wats_per_hour:))
}

fn device_handler(req:Request,conn) {
  case req.method {
    http.Delete -> todo
    http.Get -> todo
    http.Post -> {
      use json <- wisp.require_json(req)
      let res = {
        use info <- result.try(result.replace_error(decode.run(json,new_device_request_decoder()),"you sent us bad and evil json "))
        let sql = sql.new_device(conn,info.bench_id,info.wats_per_hour)
        |> result.replace_error("we failed to add this to the db :( we are so sorry we let you down")
        use _  <- result.try(sql)
        Ok(wisp.ok())
      }
      use err <- recover_or_return(res) // this returns the final result or recovers with the bellow
      error_page(err)
    }
    _ -> not_found()
  }
}

pub fn error_page(err) {
  let page = page_scaffold(html.div([],[
    html.text("Error" <> err <> "im sowwy :(")
  ]),"")
  |> element.to_document_string_builder()
  wisp.response(500)
  |> wisp.html_body(page)
}

pub fn not_found() {
  let page = page_scaffold(html.div([],[
    html.text("Not found")
  ]),"")
  |> element.to_document_string_builder()
  wisp.response(404)
  |> wisp.html_body(page)
}

fn page_scaffold(
  content: element.Element(a),
  init_json:String
) -> element.Element(a) {
  html.html([attribute.attribute("lang", "en")], [
    html.head([], [
      html.meta([attribute.attribute("charset", "UTF-8")]),
      html.meta([
        attribute.attribute("content", "width=device-width, initial-scale=1.0"),
        attribute.name("viewport"),
      ]),
      html.title([], "muse"),
      html.link([
               attribute.href("https://fonts.googleapis.com"),
               attribute.rel("preconnect"),
             ]),
             html.link([
               attribute.attribute("crossorigin", ""),
               attribute.href("https://fonts.gstatic.com"),
               attribute.rel("preconnect"),
             ]),
             html.link([
               attribute.rel("stylesheet"),
               attribute.href("https://fonts.googleapis.com/css2?family=Forum&display=swap"),
      ]),
      html.link([
                attribute.href("https://fonts.googleapis.com"),
                attribute.rel("preconnect"),
              ]),
              html.link([
                attribute.attribute("crossorigin", ""),
                attribute.href("https://fonts.gstatic.com"),
                attribute.rel("preconnect"),
              ]),
              html.link([
                attribute.rel("stylesheet"),
                attribute.href("https://fonts.googleapis.com/css2?family=Forum&family=Quicksand:wght@300..700&display=swap"),
              ]),
      html.script(
        [attribute.src("/static/static/frontend.mjs"), attribute.type_("module")],
        init_json,
      ),
      html.link([
        attribute.href("static/static/frontend.css"),
        attribute.rel("stylesheet"),
      ]),
    ]),
    html.body([], [html.div([attribute.id("app")], [
      content
    ])]),
  ])
}
