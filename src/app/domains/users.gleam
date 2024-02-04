import app/helpers.{type Context}
import gleam/dynamic
import gleam/http.{Get}
import gleam/int
import gleam/json
import gleam/pgo.{type Returned, Returned}
import wisp.{type Request, type Response}

pub type User {
  RegisteredUser(name: String, email: String)
  DoesNotExist
}

//
// This request handler is used for requests to `/users/:id`.
//
pub fn get(req: Request, ctx: Context, id: String) -> Response {
  // Dispatch to the appropriate handler based on the HTTP method.
  case req.method {
    Get -> get_person(ctx, id)
    _ -> wisp.method_not_allowed([Get])
  }
}

fn get_person(ctx: Context, id: String) -> Response {
  // Parse the :id query parameter
  let assert Ok(u_id) = int.parse(id)

  // Construct the sql query
  let sql =
    "
    SELECT name, email
    FROM users
    WHERE id = $1
  "

  // Define a dynamic tuple for the returned sql value
  let user = dynamic.tuple2(dynamic.string, dynamic.string)

  // Execute the sql query
  let maybe_user: User = case pgo.execute(sql, ctx.db, [pgo.int(u_id)], user) {
    Ok(Returned(_rows, [user])) -> RegisteredUser(user.0, user.1)
    _ -> DoesNotExist
  }

  // Return the correct response
  case maybe_user {
    RegisteredUser(name, email) -> {
      let name = #("name", json.string(name))
      let email = #("email", json.string(email))
      let object = json.object([name, email])
      let response = json.to_string_builder(object)

      wisp.json_response(response, 200)
    }
    DoesNotExist -> send_404("User not found.")
  }
}

fn send_404(reason: String) -> Response {
  let code = #("code", json.int(404))
  let error = #("error", json.string(reason))
  let object = json.object([code, error])
  let response = json.to_string_builder(object)

  wisp.json_response(response, 404)
}
