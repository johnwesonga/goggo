import app/db
import gleam/bool
import gleam/string_tree
import wisp

pub type Context {
  Context(static_directory: String, todos: List(db.Todo))
}

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- default_responses

  handle_request(req)
}

pub fn default_responses(handle_request: fn() -> wisp.Response) -> wisp.Response {
  let response = handle_request()

  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 ->
      "<h1>Not Found</h1>"
      |> string_tree.from_string
      |> wisp.html_response(response.status)

    400 | 422 ->
      "<h1>Bad request</h1>"
      |> string_tree.from_string
      |> wisp.html_response(response.status)

    413 ->
      "<h1>Request entity too large</h1>"
      |> string_tree.from_string
      |> wisp.html_response(response.status)

    500 ->
      "<h1>Internal server error</h1>"
      |> string_tree.from_string
      |> wisp.html_response(response.status)

    _ -> response
  }
}
