import gleam/dynamic/decode
import gleam/int
import gleam/list
import sqlight
import wisp

pub type Todo {
  Todo(id: Int, title: String, completed: Int)
}

fn todo_decoder() -> decode.Decoder(Todo) {
  {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use completed <- decode.field(2, decode.int)
    decode.success(Todo(id: id, title: title, completed: completed))
  }
}

fn db_directory() -> String {
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  priv_directory <> "/data/"
}

pub fn open_db_conn() -> Result(sqlight.Connection, sqlight.Error) {
  let db_conn = sqlight.open(db_directory() <> "app.db")
  case db_conn {
    Ok(conn) -> {
      echo "Database opened successfully at " <> db_directory()
      Ok(conn)
    }
    Error(err) -> {
      Error(err)
    }
  }
}

pub fn get_todos() -> Result(List(Todo), sqlight.Error) {
  let assert Ok(conn) = open_db_conn()
  let todos =
    sqlight.query(
      "SELECT * FROM todos ORDER BY id DESC",
      on: conn,
      with: [],
      expecting: todo_decoder(),
    )

  case todos {
    Ok(results) -> {
      wisp.log_info(
        "Retrieved " <> int.to_string(list.length(results)) <> " todos.",
      )
      Ok(results)
    }
    Error(error) -> {
      wisp.log_error("Error retrieving todos: " <> error.message)
      Error(error)
    }
  }
}
