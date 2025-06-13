import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h1, img, p}

pub fn root() -> Element(t) {
  h1([], [text("Homepage")])
}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  let logo_image =
    img([
      attribute.src("/static/images/todo.png"),
      attribute.alt("My Awesome Image"),
      attribute.width(150),
      attribute.height(150),
    ])
  html.html([], [
    html.head([], [
      html.title([], "Goggo"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href(
          "https://cdn.jsdelivr.net/npm/bootstrap@5.3.6/dist/css/bootstrap.min.css",
        ),
      ]),
    ]),
    html.body([], [
      div([class("container")], [
        div([class("logo")], [logo_image]),
        div([class("row")], [div([class("col-md-12")], elements)]),
      ]),
    ]),
  ])
}

pub fn error_page(message: String) -> Element(t) {
  div([class("alert alert-danger")], [p([], [text(message)])])
}
