import app/db
import app/pages/home
import app/pages/todos_page
import app/web
import gleam/list
import gleam/result
import gleam/string
import lustre/element
import wisp.{type Request, type Response}

pub fn fetch_todos() -> Response {
  let todos_result = db.get_todos()
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

pub fn edit_todo(_req: Request, _ctx: web.Context, id: String) -> Response {
  // This function is not implemented yet.
  let todo_result = db.get_todo(id)
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

pub fn post_create_todo(req: Request, _ctx: web.Context) -> Response {
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

        wisp.ok()
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
  let result = db.delete_todo(id)
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
