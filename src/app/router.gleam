import app/helpers.{type Context}
import app/domains/users
import app/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["users", id] -> users.get(req, ctx, id)
    _ -> wisp.not_found()
  }
}
