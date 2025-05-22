import app/db
import gleam/list
import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h1}

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
    html.body([], elements),
  ])
}

pub fn todo_item(item: db.Todo) -> Element(t) {
  let completed_class: String = {
    case item.completed {
      1 -> "todo--completed"
      _ -> ""
    }
  }
  let completed_value: String = {
    case item.completed {
      1 -> "true"
      _ -> "false"
    }
  }

  div([class("todo " <> completed_class)], [
    div([class("todo__inner")], [
      div([class("todo__title")], [text(item.title)]),
      div([class("todo__completed")], [text("Completed: " <> completed_value)]),
    ]),
  ])
}

pub fn todos_list(todos: List(db.Todo)) -> Element(t) {
  div([class("todos")], [
    h1([], [text("Todo List")]),
    div([class("todos__inner")], [
      div(
        [class("todos__list")],
        todos
          |> list.map(todo_item),
      ),
    ]),
  ])
}

pub fn error_page(message: String) -> Element(t) {
  div([class("error")], [h1([], [text(message)])])
}
