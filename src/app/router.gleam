import app/pages/home
import app/routes/todos_routes.{
  create_todo_route, delete_todo_route, edit_todo_route, fetch_todo_route_v1,
  fetch_todos_route, fetch_todos_route_v1, update_todo_route,
}
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
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> {
      wisp.redirect("/todos")
    }

    ["todos"] -> {
      use <- wisp.require_method(req, http.Get)
      fetch_todos_route()
    }
    ["todos", "add"] -> {
      use <- wisp.require_method(req, http.Post)
      create_todo_route(req, ctx)
    }
    // todos/edit/{id}
    ["todos", "edit", id] -> {
      use <- wisp.require_method(req, http.Get)
      // Here you would handle editing a todo item by its ID.
      // The edit_todo function is not implemented yet, so we will return a placeholder response.
      edit_todo_route(req, ctx, id)
    }
    // todos/update/{id}
    ["todos", "update", id] -> {
      use <- wisp.require_method(req, http.Post)
      update_todo_route(req, ctx, id)
    }
    // todos/delete/{id}
    ["todos", "delete", id] -> {
      use <- wisp.require_method(req, http.Get)
      // Here you would handle deleting a todo item by its ID.
      delete_todo_route(req, ctx, id)
    }
    // /api/v1/todos
    ["api", "v1", "todos"] -> {
      use <- wisp.require_method(req, http.Get)
      fetch_todos_route_v1(req, ctx)
    }

    // /api/v1/todos/{id}
    ["api", "v1", "todos", id] -> {
      use <- wisp.require_method(req, http.Get)
      fetch_todo_route_v1(req, ctx, id)
    }

    // /api/v1/todos/{id}/delete
    ["api", "v1", "todos", id, "delete"] -> {
      use <- wisp.require_method(req, http.Delete)
      delete_todo_route(req, ctx, id)
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
