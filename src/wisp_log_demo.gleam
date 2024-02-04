import app/router
import app/helpers
import gleam/erlang/process
import gleam/io
import gleam/pgo
import gleam/option.{Some}
import mist
import wisp

pub fn main() {
  // Initialize the logging
  wisp.configure_logger()

  // Create a secret key base
  let secret_key_base = wisp.random_string(64)

  // Create the database connection
  let db =
    pgo.connect(
      pgo.Config(
        ..pgo.default_config(),
        host: "localhost",
        user: "postgres",
        password: Some("postgres"),
        database: "app_dev",
        pool_size: 15,
      ),
    )

  // Create the context to hold the database connections
  let ctx = helpers.Context(db: db)

  // Create the request handler using our context
  let handler = router.handle_request(_, ctx)

  // Start the server
  let assert Ok(_) =
    handler
    |> wisp.mist_handler(secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  io.debug(which_applications())

  process.sleep_forever()
}

@external(erlang, "application", "which_applications")
fn which_applications() -> whatever
