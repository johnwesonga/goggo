import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h1, p}

pub fn root() -> Element(t) {
  h1([], [text("Homepage")])
}

pub fn layout(elements: List(Element(t))) -> Element(t) {
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
    html.body([], [div([class("container")], elements)]),
  ])
}

pub fn error_page(message: String) -> Element(t) {
  div([class("alert alert-danger")], [p([], [text(message)])])
}
