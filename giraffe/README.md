# CardsProject

F# + Giraffe REST API with Dapper + SQLite.

## Requirements

- .NET 8 SDK

## Run

```bash
cd src
dotnet run
```

API: http://localhost:5000/api/

## Test

```bash
cd tests
dotnet test
```

## Structure

```
src/
  Database.fs          — SQLite connection + schema init
  {App}/{Model}Types.fs  — F# record types, DTOs, Dapper DB module
  {App}/{Model}Handler.fs — Giraffe HTTP handlers + routes
  Program.fs           — entry point, router wiring
  schema.sql           — SQLite DDL (auto-applied on startup)
tests/
  TestHelpers.fs       — WebApplicationFactory for xUnit
  {App}/{Model}Tests.fs — integration tests (xUnit)
```

## Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/{plural}     | List all |
| POST   | /api/{plural}     | Create |
| GET    | /api/{plural}/{id} | Get by id |
| PUT    | /api/{plural}/{id} | Replace |
| PATCH  | /api/{plural}/{id} | Partial update |
| DELETE | /api/{plural}/{id} | Delete |
