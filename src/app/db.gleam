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

pub fn close_db_conn(conn: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  let close_result = sqlight.close(conn)
  case close_result {
    Ok(_) -> {
      echo "Database connection closed successfully."
      Ok(Nil)
    }
    Error(err) -> {
      echo "Error closing database connection: " <> err.message
      Error(err)
    }
  }
}

/// Retrieves all todo items from the database, ordered by ID in descending order.
///
/// # Returns
/// A `Result` containing a list of all todo items or a database error.
///
/// # Logs
/// - Logs the number of retrieved todo items.
/// - Logs any errors encountered during the database query.
pub fn get_todos_old() -> Result(List(Todo), sqlight.Error) {
  let assert Ok(conn) = open_db_conn()
  let todos =
    sqlight.query(
      "SELECT * FROM todos ORDER BY id DESC",
      on: conn,
      with: [],
      expecting: todo_decoder(),
    )

  case todos {
    // If no todos are found, return an empty list
    Ok([]) -> {
      wisp.log_info("No todos found in the database.")
      Ok([])
    }
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

pub fn get_todos(conn: sqlight.Connection) -> Result(List(Todo), sqlight.Error) {
  let todos =
    sqlight.query(
      "SELECT * FROM todos ORDER BY id DESC",
      on: conn,
      with: [],
      expecting: todo_decoder(),
    )
  // close the database connection after the operation
  let assert Ok(_) = close_db_conn(conn)
  case todos {
    // If no todos are found, return an empty list
    Ok([]) -> {
      wisp.log_info("No todos found in the database.")
      Ok([])
    }
    Ok(results) -> {
      wisp.log_info(
        "Retrieved " <> int.to_string(list.length(results)) <> " todos.",
      )
      //  let assert Ok(_) = close_db_conn(conn)
      Ok(results)
    }
    Error(error) -> {
      wisp.log_error("Error retrieving todos: " <> error.message)
      Error(error)
    }
  }
}

/// Retrieves a specific todo item by its ID from the database.
///
/// # Arguments
/// - `conn`: A sqlite connection object.
/// - `id`: A string representation of the todo item's ID.
///
/// # Returns
/// A `Result` containing a list of matching todo items or a database error.
///
/// # Logs
/// - Logs the SQL query and the number of retrieved todo items.
/// - Logs any errors encountered during the database query.
pub fn get_todo(
  conn: sqlight.Connection,
  id: String,
) -> Result(List(Todo), sqlight.Error) {
  let sql = "SELECT * FROM todos WHERE id = ? ORDER BY id DESC"
  wisp.log_info("Querying for todo with ID: " <> id <> " SQL: " <> sql)
  // Ensure the ID is a valid integer
  let todo_item =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(id)],
      expecting: todo_decoder(),
    )
  //let assert Ok(_) = close_db_conn(conn)
  case todo_item {
    // If no todo is found, return an empty list
    Ok([]) -> {
      wisp.log_info("No todo found with ID: " <> id)
      Ok([])
    }
    Ok(result) -> {
      wisp.log_info(
        "Retrieved " <> int.to_string(list.length(result)) <> " todo.",
      )
      Ok(result)
    }

    Error(error) -> {
      wisp.log_error("Error retrieving todos: " <> error.message)
      Error(error)
    }
  }
}

/// Deletes a specific todo item by its ID from the database.
///
/// # Arguments
/// - `id`: A string representation of the todo item's ID to delete.
///
/// # Returns
/// A `Result` containing the number of affected rows or a database error.
///
/// # Logs
/// - Logs the deletion attempt with the todo ID.
/// - Logs successful deletion with the number of affected rows.
/// - Logs any errors encountered during the database operation.
pub fn delete_todo(
  conn: sqlight.Connection,
  id: String,
) -> Result(Int, sqlight.Error) {
  let sql = "DELETE FROM todos WHERE id = ? RETURNING id"
  // Use parameterized query to prevent SQL injection
  wisp.log_info("Attempting to delete todo with ID: " <> id)

  let item =
    sqlight.query(
      sql,
      on: conn,
      with: [sqlight.text(id)],
      expecting: decode.list(decode.int),
    )
    |> echo
  let assert Ok(_) = close_db_conn(conn)

  case item {
    Ok([]) -> {
      echo "Todo with ID " <> id <> " not found"
      Ok(0)
    }
    Ok(_) -> {
      echo "Todo with ID " <> id <> " deleted successfully."
      Ok(1)
    }
    Error(error) -> {
      echo "Error deleting todo with ID " <> id <> ": " <> error.message

      Error(error)
    }
  }
}

/// Adds a new todo item to the database with the given title.
/// # Arguments
/// - `title`: The title of the todo item to add.
/// # Returns
/// A `Result` containing the number of affected rows (1 for success) or a database error.
/// # Logs
/// - Logs the addition of the todo item with its title.
/// - Logs any errors encountered during the database operation.
/// # Example
/// ```gleam
/// let result = db.add_todo("Buy groceries")
/// case result {
///   Ok(rows) -> wisp.log_info("Added todo, rows affected: " <> int.to_string(rows))
///   Error(err) -> wisp.log_error("Failed to add todo: " <> err.message)
/// }
/// ```
pub fn add_todo(title: String) -> Result(Int, sqlight.Error) {
  let assert Ok(conn) = open_db_conn()
  let sql = "INSERT INTO todos (title, completed) VALUES (?, 0)"
  wisp.log_info("Adding todo with title: " <> title)

  let result =
    sqlight.query(
      sql,
      conn,
      [sqlight.text(title)],
      expecting: decode.list(decode.int),
    )

  case result {
    Ok(_) -> {
      wisp.log_info("Todo added successfully.")
      Ok(1)
      // Return 1 to indicate one row affected
    }
    Error(error) -> {
      wisp.log_error("Error adding todo: " <> error.message)
      Error(error)
    }
  }
}

pub fn update_todo(
  conn: sqlight.Connection,
  id: String,
  title: String,
  completed: Int,
) -> Result(Int, sqlight.Error) {
  let sql = "UPDATE todos SET title = ?, completed = ? WHERE id = ?"
  wisp.log_info("Updating todo with ID: " <> id <> " and title: " <> title)
  let result =
    sqlight.query(
      sql,
      conn,
      [sqlight.text(title), sqlight.int(completed), sqlight.text(id)],
      expecting: decode.list(decode.int),
    )
  let assert Ok(_) = close_db_conn(conn)
  case result {
    Ok(_) -> {
      wisp.log_info("Todo updated successfully.")
      Ok(1)
    }
    Error(error) -> {
      wisp.log_error("Error updating todo: " <> error.message)
      Error(error)
    }
  }
}

/// Initializes the database by creating the necessary tables if they do not exist.
/// # Returns
/// A `Result` indicating success or failure of the initialization.
pub fn init_db(conn: sqlight.Connection) -> Result(Nil, sqlight.Error) {
  //let assert Ok(conn) = open_db_conn()
  let sql =
    "
    CREATE TABLE IF NOT EXISTS todos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      completed INTEGER DEFAULT 0
    );
  "

  wisp.log_info("Initializing database and creating todos table if needed.")
  let assert Ok(_) = sqlight.exec(sql, conn)
}

// seed the database with some initial data
pub fn seed_db(
  conn: sqlight.Connection,
  seed_data: List(Todo),
) -> Result(Nil, sqlight.Error) {
  wisp.log_info("Seeding database with initial todo items.")
  let sql = "INSERT INTO todos (id, title, completed) VALUES (?, ?, ?)"
  // Use parameterized query to prevent SQL injection
  // Iterate over the list of todos and insert each one into the database 
  seed_data
  |> list.each(fn(item) {
    echo "Seeding todo: " <> item.title
    let result =
      sqlight.query(
        sql,
        conn,
        [
          sqlight.int(item.id),
          sqlight.text(item.title),
          sqlight.int(item.completed),
        ],
        expecting: decode.list(decode.int),
      )
    case result {
      Ok(_) -> {
        echo "Todo seeded successfully: " <> item.title
      }
      Error(_) -> {
        echo "Error seeding todo: " <> item.title
      }
    }
  })

  Ok(Nil)
}
