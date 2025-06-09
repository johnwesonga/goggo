import app/db
import gleam/int
import gleam/list
import gleeunit
import gleeunit/should
import sqlight

pub fn main() {
  gleeunit.main()
}

pub fn fetch_todos_test() {
  // This is a placeholder for the actual test implementation.
  // You would typically call the function you want to test and assert the expected outcome.
  let sample_todos = [
    db.Todo(1, "Sample Todo 1", 0),
    db.Todo(2, "Sample Todo 2", 1),
  ]
  //let assert Ok(conn) = db.open_db_conn()
  let todos = db.get_todos()
  case todos {
    Ok(results) -> {
      should.equal(list.length(results), list.length(sample_todos))
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
}

pub fn edit_todo_test() {
  // This is a placeholder for the actual test implementation.
  // You would typically call the function you want to test and assert the expected outcome.
  1
  |> should.equal(1)
}

pub fn render_page_test() {
  // This is a placeholder for the actual test implementation.
  // You would typically call the function you want to test and assert the expected outcome.
  1
  |> should.equal(1)
}
