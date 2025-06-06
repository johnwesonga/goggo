import app/db
import app/web
import gleam/list
import gleam/result
import gleam/string
import sqlight
import wisp.{type Request, type Response}

pub fn edit_create_todo(req: Request, _ctx: web.Context) -> Response {
  // This function is not implemented yet.
  wisp.not_found()
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
        let assert Ok(conn) = db.open_db_conn()
        let sql =
          "INSERT INTO todos (title, completed) VALUES ('"
          <> item_title
          <> "', 0)"
        let assert Ok(Nil) = sqlight.exec(sql, conn)
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
