import app/db
import gleam/int
import gleam/list
import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html.{div}

import app/pages/home.{layout, root}

pub fn layout_with_todos(todos: List(db.Todo)) -> Element(t) {
  let todos_content = todos_table(todos)
  layout([root(), todos_content])
}

pub fn todos_table_item(item: db.Todo) -> Element(t) {
  let completed_value: String = {
    case item.completed {
      1 -> "Yes"
      _ -> "No"
    }
  }
  html.tr([], [
    html.td([], [text(int.to_string(item.id))]),
    html.td([], [text(item.title)]),
    html.td([], [text(completed_value)]),
  ])
}

pub fn todos_table(todos: List(db.Todo)) -> Element(t) {
  // Render a table of todos
  // Each row will display the ID, title, and completion status of the todo item.
  div([class("todos-table")], [
    div([class("todos_form")], [todos_input_form()]),
    html.table([class("table table-hover")], [
      html.thead([class("thead-dark")], [
        html.tr([], [
          html.th([class("col")], [text("ID")]),
          html.th([class("col")], [text("Title")]),
          html.th([class("col")], [text("Completed")]),
        ]),
      ]),
      html.tbody(
        [],
        todos
          |> list.map(todos_table_item),
      ),
    ]),
  ])
}

pub fn todos_input_form() -> Element(t) {
  html.form(
    [
      class("todo-form"),
      attribute.method("POST"),
      attribute.action("/todos/add"),
    ],
    [
      html.div([class("mb-3")], [
        html.label([class("form-label"), attribute.for("todo-title")], [
          text("Todo Title"),
        ]),
        html.input([
          class("form-control"),
          attribute.type_("text"),
          attribute.id("todo-title"),
          attribute.name("todo-title"),
          attribute.placeholder("Enter todo title"),
        ]),
      ]),
      html.button([class("btn btn-primary")], [text("Add Todo")]),
    ],
  )
}
