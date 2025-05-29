import wisp.{type Request, type Response}

pub fn post_create_todo(req: Request) -> Response {
  use _form <- wisp.require_form(req)
  wisp.redirect("/todos")
  |> wisp.set_cookie(
    req,
    "message",
    "Todo created successfully!",
    wisp.PlainText,
    60 * 60 * 24,
  )
}
