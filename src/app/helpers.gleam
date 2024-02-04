import gleam/pgo

pub type Context {
  Context(db: pgo.Connection)
}
