import gleam/dynamic/decode
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

fn db_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("app")
  echo "Private directory: " <> priv_directory
  priv_directory <> "/data/"
}

fn open_db_conn() {
  let db_conn = sqlight.open(db_directory() <> "app.db")
  case db_conn {
    Ok(conn) -> {
      echo "Database connection established."
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
      "SELECT * FROM todos",
      on: conn,
      with: [],
      expecting: todo_decoder(),
    )

  case todos {
    Ok(results) -> {
      echo "Retrieved todos successfully."
      Ok(results)
    }
    Error(error) -> {
      echo "Error retrieving todos: " <> error.message
      Error(error)
    }
  }
}
