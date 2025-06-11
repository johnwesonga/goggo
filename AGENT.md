# Goggo - Gleam Todo App Agent Guide

## Commands
- **Build**: `gleam build` - Build the project  
- **Test all**: `gleam test` - Run all tests
- **Test single**: `gleam test <test_name>` - Run specific test (e.g., `gleam test init_db_test`)
- **Run app**: `gleam run` - Start the main application
- **Run dev**: `gleam run -m olive` - Start development server with hot reload
- **Format**: `gleam format` - Format code
- **Type check**: `gleam check` - Type check without building

## Architecture
- **Full-stack Gleam app** with Wisp web framework and Lustre frontend
- **Database**: SQLite with sqlight library for persistence
- **Entry point**: `src/app.gleam` - main server setup
- **Router**: `src/app/router.gleam` - HTTP routing logic  
- **Database layer**: `src/app/db.gleam` - Todo CRUD operations
- **Models**: Todo type with id, title, completed fields
- **Routes**: RESTful endpoints for todos (GET, POST, DELETE, UPDATE)
- **Context**: Web context holds app state

## Code Style
- **Imports**: Group by external deps, then internal modules
- **Functions**: Use `pub` for public, snake_case naming
- **Types**: PascalCase for custom types (e.g., `Todo`)
- **Error handling**: Use `Result(T, Error)` pattern consistently
- **Testing**: Use gleeunit with `should` assertions, prefix test functions with `_test`
- **Logging**: Use `wisp.log_info()`, `wisp.log_error()` for debugging
- **Database**: Always close connections, use parameterized queries for safety
