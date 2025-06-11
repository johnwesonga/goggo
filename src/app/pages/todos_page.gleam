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
    html.td([], [
      html.a(
        [
          class("btn btn-sm btn-primary"),
          attribute.href("/todos/edit/" <> int.to_string(item.id)),
        ],
        [text("Edit")],
      ),
    ]),
    html.td([], [
      html.a(
        [
          class("btn btn-sm btn-danger"),
          attribute.href("/todos/delete/" <> int.to_string(item.id)),
        ],
        [text("Delete")],
      ),
    ]),
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
          html.th([class("col")], []),
          html.th([class("col")], []),
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

pub fn todo_edit_form(todo_item: db.Todo) -> Element(t) {
  div([class("edit-todos-form")], [
    html.h2([], [text("Edit Todo: " <> todo_item.title)]),
    html.form(
      [
        class("todo-form"),
        attribute.method("POST"),
        attribute.action("/todos/update/" <> int.to_string(todo_item.id)),
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
            attribute.value(todo_item.title),
          ]),
        ]),
        html.div([class("mb-3")], [
          html.label(
            [class("form-check-label"), attribute.for("todo-completed")],
            [text("Completed")],
          ),
          html.br([]),
          html.input([
            class("form-check-input"),
            attribute.type_("checkbox"),
            attribute.id("todo-completed"),
            attribute.name("todo-completed"),
            attribute.value(int.to_string(todo_item.completed)),
            attribute.checked(todo_item.completed == 1),
          ]),
        ]),
        html.button([class("btn btn-primary")], [text("Update Todo")]),
      ],
    ),
    html.br([]),
    // Add a link to go back to the todos list
    html.a([class("btn btn-secondary"), attribute.href("/todos")], [
      text("Back to Todos List"),
    ]),
    html.br([]),
  ])
}
