import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", 0)

  Nil
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model()
}

fn init(initial_count: Int) -> Model {

}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {

}

fn update(model: Model, msg: Msg) -> Model {

}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  html.div([],[html.text("cringe")])
}
