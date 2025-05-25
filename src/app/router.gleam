import app/db
import app/pages/home
import app/pages/todos_page
import app/web
import lustre/element
import wisp.{type Request, type Response}

pub fn render_page(content: List(element.Element(t))) -> Response {
  content
  |> home.layout
  |> element.to_document_string_tree
  |> wisp.html_response(200)
}

// This module defines the routing logic for the web application.
pub fn handle_request(req: Request) -> Response {
  use _req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> {
      render_page([home.root()])
    }

    ["todos"] -> {
      let todos_result = db.get_todos()
      case todos_result {
        Ok(todos) -> {
          render_page([todos_page.todos_table(todos)])
        }
        Error(err) -> {
          [home.error_page("Error fetching todos: " <> err.message)]
          |> home.layout
          |> element.to_document_string_tree
          |> wisp.html_response(500)
        }
      }
    }
    ["todos", "add"] -> {
      // Here you would handle adding a new todo item.
      // For now, we just return a placeholder response.
      [home.error_page("Add Todo functionality is not implemented yet.")]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(501)
    }
    ["todos", "edit", id] -> {
      // Here you would handle editing a todo item by its ID.
      // For now, we just return a placeholder response.
      [
        home.error_page(
          "Edit Todo functionality is not implemented yet for ID: " <> id,
        ),
      ]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(501)
    }

    ["todos", "delete", id] -> {
      // Here you would handle deleting a todo item by its ID.
      // For now, we just return a placeholder response.
      [
        home.error_page(
          "Delete Todo functionality is not implemented yet for ID: " <> id,
        ),
      ]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(501)
    }

    _ -> {
      [home.error_page("Page not found")]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(404)
    }
  }
}
