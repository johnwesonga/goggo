import app/db
import app/web
import gleam/list
import gleam/string_tree
import lustre/attribute.{class}
import lustre/element.{type Element, text}
import lustre/element/html.{div}
import wisp.{type Request, type Response}

pub fn todos_list(todos: List(db.Todo)) -> Element(t) {
  div([class("todos")], [
    div([class("todos__inner")], [
      div(
        [class("todos__list")],
        todos
          |> list.map(todo_item),
      ),
    ]),
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

// This module defines the routing logic for the web application.
pub fn handle_request(req: Request) -> Response {
  use _req <- web.middleware(req)
  case wisp.path_segments(req) {
    [] -> {
      let body = string_tree.from_string("Welcome to the home page!")
      wisp.html_response(body, 200)
    }

    ["todos"] -> {
      let todos_result = db.get_todos()
      case todos_result {
        Ok(todos) -> {
          let el =
            div([], [
              div([class("todos")], [
                div([class("todos__inner")], [
                  div([class("todos__list")], [todos_list(todos)]),
                ]),
              ]),
            ])
          el
          |> element.to_document_string_tree
          |> wisp.html_response(200)
        }
        Error(err) -> {
          let body =
            string_tree.from_string("Error fetching todos: " <> err.message)
          wisp.html_response(body, 500)
        }
      }
    }

    _ -> {
      let body = string_tree.from_string("404 Not Found")
      wisp.html_response(body, 404)
    }
  }
}
