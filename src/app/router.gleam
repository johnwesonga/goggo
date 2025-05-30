import app/db
import app/pages/home
import app/pages/todos_page
import app/routes/todos_routes.{post_create_todo}
import app/web
import gleam/http
import lustre/element
import wisp.{type Request, type Response}

// This function renders the main page of the application with the provided content.

pub fn render_page(content: List(element.Element(t))) -> Response {
  content
  |> home.layout
  |> element.to_document_string_tree
  |> wisp.html_response(200)
}

// This module defines the routing logic for the web application.
pub fn handle_request(req: Request, ctx: web.Context) -> Response {
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
      use <- wisp.require_method(req, http.Post)
      // Here you would handle adding a new todo item.
      // For now, we just return a placeholder response.
      post_create_todo(req, ctx)
      // [home.error_page("Add Todo functionality is not implemented yet.")]
      // |> home.layout
      // |> element.to_document_string_tree
      // |> wisp.html_response(501)
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

    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()

    _ -> {
      [home.error_page("Page not found")]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(404)
    }
  }
}
