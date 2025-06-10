import app/db
import gleam/int
import gleam/list
import gleeunit
import gleeunit/should
import sqlight

pub fn main() {
  gleeunit.main()
}

const sample_todos = [
  db.Todo(200, "Sample Todo 2", 1),
  db.Todo(100, "Sample Todo 1", 0),
]

pub fn init_db_test() {
  // This is a placeholder for the actual test implementation.
  // You would typically call the function you want to test and assert the expected outcome.
  use conn <- sqlight.with_connection(":memory:")
  let assert Ok(_) = db.init_db(conn)
  // Seed the database with initial data

  // Check if the database was initialized correctly
  let assert Ok(_) = db.get_todos(conn)
  db.close_db_conn(conn)
}

pub fn fetch_todos_test() {
  // This is a placeholder for the actual test implementation.
  // You would typically call the function you want to test and assert the expected outcome.
  use conn <- sqlight.with_connection(":memory:")
  let assert Ok(_) = db.init_db(conn)

  // Seed the database with sample todos
  let assert Ok(_) = db.seed_db(conn, sample_todos)
  let todos = db.get_todos(conn)
  case todos {
    Ok(results) -> {
      should.equal(list.length(results), list.length(sample_todos))
      echo results
        |> list.map(fn(item) {
          "Todo ID: "
          <> int.to_string(item.id)
          <> ", Title: "
          <> item.title
          <> ", Completed: "
          <> int.to_string(item.completed)
        })
      echo "Fetched todos: " <> list.length(results) |> int.to_string()
      should.equal(results, sample_todos)
    }
    Error(err) -> {
      should.fail()

      should.equal(
        err,
        sqlight.SqlightError(
          sqlight.error_code_from_int(1),
          "Database error",
          -1,
        ),
      )
    }
  }
  // db.close_db_conn(conn)
}

pub fn get_todo_test() {
  use conn <- sqlight.with_connection(":memory:")
  let assert Ok(_) = db.init_db(conn)

  // Seed the database with sample todos
  let assert Ok(_) = db.seed_db(conn, sample_todos)

  // Test fetching a specific todo by ID
  let todo_result = db.get_todo(conn, "100")
  case todo_result {
    Ok(results) -> {
      should.equal(list.length(results), 1)
      let todo_item = list.first(results)
      case todo_item {
        Ok(item) -> {
          should.equal(item.id, 100)
          should.equal(item.title, "Sample Todo 1")
          should.equal(item.completed, 0)
        }
        Error(_) -> should.fail()
      }
    }
    Error(_err) -> should.fail()
  }

  // Test fetching a non-existent todo
  let fake_id = "9999999999"
  let non_existent_todo = db.get_todo(conn, fake_id)
  case non_existent_todo {
    Ok(results) -> {
      should.equal(list.length(results), 0)
      echo "No todo found with ID: " <> fake_id
    }
    Error(err) -> {
      should.fail()
      echo "Error fetching todo with ID: "
      <> fake_id
      <> ", Error: "
      <> err.message
    }
  }

  db.close_db_conn(conn)
}
