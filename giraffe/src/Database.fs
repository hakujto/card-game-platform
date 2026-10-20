module cards_project.Database

open System.Data
open Microsoft.Data.Sqlite

let createConnection (dbPath: string) : IDbConnection =
    let conn = new SqliteConnection($"Data Source={dbPath}")
    conn.Open()
    conn :> IDbConnection

let initializeSchema (conn: IDbConnection) (schemaSql: string) =
    use cmd = conn.CreateCommand()
    cmd.CommandText <- schemaSql
    cmd.ExecuteNonQuery() |> ignore
