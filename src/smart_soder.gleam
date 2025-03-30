import envoy
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
import dot_env as dot

pub fn main() {
  dot.new()
  |> dot.set_path("./.env.local")
  |> dot.set_debug(True)
  |> dot.load
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  //todo add env vars here :) we love .env
  let assert Ok(url)  = envoy.get("DATABASE_URL")
  let db = pog.url_config(url)
    |> result.unwrap(pog.default_config())
    |> pog.pool_size(15)
    |> pog.connect
  let handler = handler(_,db)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

    process.sleep_forever()
}


fn handler(req: Request,conn) -> Response {
  use <- wisp.log_request(req)
  case wisp.path_segments(req) {
    ["lab"] -> lab_handler(req,conn)
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

fn lab_handler(req: Request,conn) {
  case req.method {
    http.Delete -> not_found()
    http.Get -> not_found() //todo retrurn the server rendered html
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
        let assert Ok(device_row) = sql.new_device(conn,info.bench_id,info.wats_per_hour)
        let assert Ok(first) = list.first(device_row.rows)
        Device(first.mac_address,first.lab_id,first.number,first.status,first.wats_per_hour,first.hours_on,first.minutes_on)
        |> encode_device
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
      html.title([], "smart lab"),
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
