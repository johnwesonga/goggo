import app/db
import app/pages/home
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
          render_page([home.todos_list(todos)])
        }
        Error(err) -> {
          [home.error_page("Error fetching todos: " <> err.message)]
          |> home.layout
          |> element.to_document_string_tree
          |> wisp.html_response(500)
        }
      }
    }

    _ -> {
      [home.error_page("Page not found")]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(404)
    }
  }
}
