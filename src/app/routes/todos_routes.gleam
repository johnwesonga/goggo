import app/db
import app/pages/home
import app/pages/todos_page
import app/web
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleam/string_tree
import lustre/element
import wisp.{type Request, type Response}

pub fn fetch_todos_route() -> Response {
  let assert Ok(conn) = db.open_db_conn()
  let todos_result = db.get_todos(conn)
  case todos_result {
    Ok(todos) -> {
      // Render the todos page with the fetched todos
      [todos_page.todos_table(todos)]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(200)
    }
    Error(err) -> {
      // Handle the error when fetching todos
      [home.error_page("Error fetching todos: " <> err.message)]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(500)
    }
  }
}

pub fn edit_todo_route(_req: Request, _ctx: web.Context, id: String) -> Response {
  let assert Ok(conn) = db.open_db_conn()
  let todo_result = db.get_todo(conn, id)
  case todo_result {
    Ok(todo_result) -> {
      let todo_item = list.first(todo_result)
      case todo_item {
        Ok(item) -> {
          // Render the edit form for the todo item
          [todos_page.todo_edit_form(item)]
          |> home.layout
          |> element.to_document_string_tree
          |> wisp.html_response(200)
        }
        Error(_) ->
          [home.error_page("Todo with ID " <> id <> " not found.")]
          |> home.layout
          |> element.to_document_string_tree
          |> wisp.html_response(404)
      }
    }
    Error(_) ->
      // Handle the error when fetching the todo item
      [home.error_page("Todo with ID " <> id <> " not found.")]
      |> home.layout
      |> element.to_document_string_tree
      |> wisp.html_response(404)
  }
}

/// Handles the creation of a new todo item from a submitted form.
///
/// This function:
/// - Extracts form data from the incoming HTTP request.
/// - Logs all form field names and values for debugging purposes.
/// - Attempts to retrieve the "todo-title" field from the form data.
/// - Validates that the todo title is not empty; if it is, logs an error and returns a bad request response.
/// - If the title is valid, inserts the new todo into the database and logs the operation.
/// - On success, redirects the user to the "/todos" page and sets a cookie.
/// - On failure (e.g., missing or empty title), returns a bad request response.
///
/// # Parameters
/// - `req`: The HTTP request containing the form data.
/// - `_ctx`: The web context (unused).
///
/// # Returns
/// - A `Response` that either redirects to the todos list on success or returns a bad request on failure.
pub fn create_todo_route(req: Request, _ctx: web.Context) -> Response {
  use form <- wisp.require_form(req)
  list.map(form.values, fn(pair) {
    let #(name, value) = pair
    name <> ": " <> value
  })
  |> string.join(with: "\n")
  |> wisp.log_info

  let result = {
    use item_title <- result.try(list.key_find(form.values, "todo-title"))
    // Ensure the title is not empty
    case string.is_empty(item_title) {
      True -> {
        wisp.log_error("Todo title cannot be empty.")
        wisp.bad_request()
      }
      _ -> {
        wisp.log_info("Creating todo with title: " <> item_title)
        // Insert the todo into the database
        let assert Ok(_) = db.add_todo(item_title)
        wisp.log_info("Todo created successfully.")

        wisp.created()
      }
    }
    Ok(Nil)
  }
  case result {
    Ok(_) ->
      wisp.redirect("/todos")
      |> wisp.set_cookie(req, "todos", "todos", wisp.PlainText, 60 * 60 * 24)
    Error(_) -> wisp.bad_request()
  }
}

pub fn delete_todo_route(
  req: Request,
  _ctx: web.Context,
  id: String,
) -> Response {
  wisp.log_info("Deleting todo with ID: " <> id)
  let assert Ok(conn) = db.open_db_conn()
  let result = db.delete_todo(conn, id)
  case result {
    Ok(_) -> {
      wisp.redirect("/todos")
      |> wisp.set_cookie(req, "todos", "todos", wisp.PlainText, 60 * 60 * 24)
    }
    Error(err) -> {
      wisp.log_error(
        "Error deleting todo with ID " <> id <> ": " <> err.message,
      )
      wisp.internal_server_error()
    }
  }
}

pub fn update_todo_route(
  req: Request,
  _ctx: web.Context,
  id: String,
) -> Response {
  use form <- wisp.require_form(req)
  list.map(form.values, fn(pair) {
    let #(name, value) = pair
    name <> ": " <> value
  })
  |> string.join(with: "\n")
  |> wisp.log_info

  let assert Ok(item_title) = list.key_find(form.values, "todo-title")

  let item_completed = case list.key_find(form.values, "todo-completed") {
    Ok(_) -> 1
    Error(_) -> 0
  }
  let assert Ok(conn) = db.open_db_conn()
  let result = db.update_todo(conn, id, item_title, item_completed)
  case result {
    Ok(_) -> {
      wisp.created()
      wisp.redirect("/todos")
      |> wisp.set_cookie(req, "todos", "todos", wisp.PlainText, 60 * 60 * 24)
    }
    Error(err) -> {
      wisp.log_error("Error updating todo: " <> err.message)
      wisp.internal_server_error()
    }
  }
}

pub fn fetch_todos_route_v1(_req: Request, _ctx: web.Context) -> Response {
  let assert Ok(conn) = db.open_db_conn()
  let todos_result = db.get_todos(conn)
  case todos_result {
    Ok(todos) -> {
      let todos_json = todos_to_json(todos) |> string_tree.from_string
      wisp.json_response(todos_json, 200)
    }
    Error(err) -> {
      wisp.log_error("Error fetching todos: " <> err.message)
      wisp.response(500)
      |> wisp.set_header("Content-Type", "application/json")
      // Handle the error when fetching todos
    }
  }
}

pub fn fetch_todo_route_v1(
  _req: Request,
  _ctx: web.Context,
  id: String,
) -> Response {
  let assert Ok(conn) = db.open_db_conn()
  let todos_result = db.get_todo(conn, id)
  case todos_result {
    Ok(todos) -> {
      let todos_json = todos_to_json(todos) |> string_tree.from_string
      wisp.json_response(todos_json, 200)
    }
    Error(err) -> {
      wisp.log_error("Error fetching todos: " <> err.message)
      wisp.response(500)
      |> wisp.set_header("Content-Type", "application/json")
      // Handle the error when fetching todos
    }
  }
}

fn todos_to_json(items: List(db.Todo)) -> String {
  "["
  <> items
  |> list.map(item_to_json)
  |> string.join(",")
  <> "]"
}

fn item_to_json(item: db.Todo) -> String {
  json.object([
    #("id", json.int(item.id)),
    #("title", json.string(item.title)),
    #("completed", json.int(item.completed)),
  ])
  |> json.to_string
}
