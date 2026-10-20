module cards_project.tournaments.MatchTypes

open System.Data

type MatchStatus =
    | Pending
    | Active
    | Completed
    | BYE
    | Draw

    static member ToString = function
        | Pending -> "Pending"
        | Active -> "Active"
        | Completed -> "Completed"
        | BYE -> "BYE"
        | Draw -> "Draw"

    static member FromString s =
        match s with
        | "Pending" -> Pending
        | "Active" -> Active
        | "Completed" -> Completed
        | "BYE" -> BYE
        | "Draw" -> Draw
        | _ -> failwithf "Unknown MatchStatus: %s" s

[<CLIMutable>]
type MatchRow = {
    Id: int64
    TableNumber: int64 option
    Status: string
    Player1Wins: int
    Player2Wins: int
    StartedAt: string option
    EndedAt: string option
    ResultNotes: string option
    RoundId: int64
    Player1Id: int64
    Player2Id: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type MatchDto = {
    id: int64
    table_number: int option
    status: string
    player1_wins: int
    player2_wins: int
    startedAt: string option
    endedAt: string option
    result_notes: string option
    round_id: int64
    player1_id: int64
    player2_id: int64 option
    created_at: string
    updated_at: string
}

let matchToDto (r: MatchRow) : MatchDto = {
    id = r.Id
    table_number = r.TableNumber |> Option.map int
    status = r.Status
    player1_wins = r.Player1Wins
    player2_wins = r.Player2Wins
    startedAt = r.StartedAt
    endedAt = r.EndedAt
    result_notes = r.ResultNotes
    round_id = r.RoundId
    player1_id = r.Player1Id
    player2_id = r.Player2Id
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type MatchCreateRequest = {
    table_number: int option
    status: string
    player1_wins: int
    player2_wins: int
    started_at: string option
    ended_at: string option
    result_notes: string option
    round_id: int64
    player1_id: int64
    player2_id: int64 option
}

type MatchUpdateRequest = {
    table_number: int option option
    status: string option
    player1_wins: int option
    player2_wins: int option
    started_at: string option option
    ended_at: string option option
    result_notes: string option option
    round_id: int64 option
    player1_id: int64 option
    player2_id: int64 option
}

module MatchDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, created_at, updated_at FROM matches"
        conn.Query<MatchRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, created_at, updated_at FROM matches WHERE id = @id"
        conn.QueryFirstOrDefault<MatchRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: MatchCreateRequest) =
        let sql = "INSERT INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id) VALUES (@table_number, @status, @player1_wins, @player2_wins, @started_at, @ended_at, @result_notes, @round_id, @player1_id, @player2_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["table_number"] <- match dto.table_number with Some v -> box v | None -> null
        p.["status"] <- box dto.status
        p.["player1_wins"] <- box dto.player1_wins
        p.["player2_wins"] <- box dto.player2_wins
        p.["started_at"] <- match dto.started_at with Some v -> box v | None -> null
        p.["ended_at"] <- match dto.ended_at with Some v -> box v | None -> null
        p.["result_notes"] <- match dto.result_notes with Some v -> box v | None -> null
        p.["round_id"] <- box dto.round_id
        p.["player1_id"] <- box dto.player1_id
        p.["player2_id"] <- match dto.player2_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: MatchCreateRequest) =
        let sql = "UPDATE matches SET table_number = @table_number, status = @status, player1_wins = @player1_wins, player2_wins = @player2_wins, started_at = @started_at, ended_at = @ended_at, result_notes = @result_notes, round_id = @round_id, player1_id = @player1_id, player2_id = @player2_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["table_number"] <- match dto.table_number with Some v -> box v | None -> null
        p.["status"] <- box dto.status
        p.["player1_wins"] <- box dto.player1_wins
        p.["player2_wins"] <- box dto.player2_wins
        p.["started_at"] <- match dto.started_at with Some v -> box v | None -> null
        p.["ended_at"] <- match dto.ended_at with Some v -> box v | None -> null
        p.["result_notes"] <- match dto.result_notes with Some v -> box v | None -> null
        p.["round_id"] <- box dto.round_id
        p.["player1_id"] <- box dto.player1_id
        p.["player2_id"] <- match dto.player2_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: MatchUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.table_number |> Option.iter (fun v -> sets.Add("table_number = @table_number"); d.["table_number"] <- match v with Some s -> box s | None -> null)
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.player1_wins |> Option.iter (fun v -> sets.Add("player1_wins = @player1_wins"); d.["player1_wins"] <- box v)
        patch.player2_wins |> Option.iter (fun v -> sets.Add("player2_wins = @player2_wins"); d.["player2_wins"] <- box v)
        patch.started_at |> Option.iter (fun v -> sets.Add("started_at = @started_at"); d.["started_at"] <- match v with Some s -> box s | None -> null)
        patch.ended_at |> Option.iter (fun v -> sets.Add("ended_at = @ended_at"); d.["ended_at"] <- match v with Some s -> box s | None -> null)
        patch.result_notes |> Option.iter (fun v -> sets.Add("result_notes = @result_notes"); d.["result_notes"] <- match v with Some s -> box s | None -> null)
        patch.round_id |> Option.iter (fun v -> sets.Add("round_id = @round_id"); d.["round_id"] <- box v)
        patch.player1_id |> Option.iter (fun v -> sets.Add("player1_id = @player1_id"); d.["player1_id"] <- box v)
        patch.player2_id |> Option.iter (fun v -> sets.Add("player2_id = @player2_id"); d.["player2_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE matches SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM matches WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE matches SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
