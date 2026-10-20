module cards_project.tournaments.TournamentRoundTypes

open System.Data

type TournamentRoundStatus =
    | Pending
    | Active
    | Completed

    static member ToString = function
        | Pending -> "Pending"
        | Active -> "Active"
        | Completed -> "Completed"

    static member FromString s =
        match s with
        | "Pending" -> Pending
        | "Active" -> Active
        | "Completed" -> Completed
        | _ -> failwithf "Unknown TournamentRoundStatus: %s" s

[<CLIMutable>]
type TournamentRoundRow = {
    Id: int64
    RoundNumber: int
    Status: string
    StartedAt: string option
    EndedAt: string option
    TimeLimitMinutes: int
    TournamentId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TournamentRoundDto = {
    id: int64
    round_number: int
    status: string
    startedAt: string option
    endedAt: string option
    time_limit_minutes: int
    tournament_id: int64
    created_at: string
    updated_at: string
}

let tournament_roundToDto (r: TournamentRoundRow) : TournamentRoundDto = {
    id = r.Id
    round_number = r.RoundNumber
    status = r.Status
    startedAt = r.StartedAt
    endedAt = r.EndedAt
    time_limit_minutes = r.TimeLimitMinutes
    tournament_id = r.TournamentId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TournamentRoundCreateRequest = {
    round_number: int
    status: string
    started_at: string option
    ended_at: string option
    time_limit_minutes: int
    tournament_id: int64
}

type TournamentRoundUpdateRequest = {
    round_number: int option
    status: string option
    started_at: string option option
    ended_at: string option option
    time_limit_minutes: int option
    tournament_id: int64 option
}

module TournamentRoundDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, created_at, updated_at FROM tournament_rounds"
        conn.Query<TournamentRoundRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, created_at, updated_at FROM tournament_rounds WHERE id = @id"
        conn.QueryFirstOrDefault<TournamentRoundRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TournamentRoundCreateRequest) =
        let sql = "INSERT INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id) VALUES (@round_number, @status, @started_at, @ended_at, @time_limit_minutes, @tournament_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["round_number"] <- box dto.round_number
        p.["status"] <- box dto.status
        p.["started_at"] <- match dto.started_at with Some v -> box v | None -> null
        p.["ended_at"] <- match dto.ended_at with Some v -> box v | None -> null
        p.["time_limit_minutes"] <- box dto.time_limit_minutes
        p.["tournament_id"] <- box dto.tournament_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TournamentRoundCreateRequest) =
        let sql = "UPDATE tournament_rounds SET round_number = @round_number, status = @status, started_at = @started_at, ended_at = @ended_at, time_limit_minutes = @time_limit_minutes, tournament_id = @tournament_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["round_number"] <- box dto.round_number
        p.["status"] <- box dto.status
        p.["started_at"] <- match dto.started_at with Some v -> box v | None -> null
        p.["ended_at"] <- match dto.ended_at with Some v -> box v | None -> null
        p.["time_limit_minutes"] <- box dto.time_limit_minutes
        p.["tournament_id"] <- box dto.tournament_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TournamentRoundUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.round_number |> Option.iter (fun v -> sets.Add("round_number = @round_number"); d.["round_number"] <- box v)
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.started_at |> Option.iter (fun v -> sets.Add("started_at = @started_at"); d.["started_at"] <- match v with Some s -> box s | None -> null)
        patch.ended_at |> Option.iter (fun v -> sets.Add("ended_at = @ended_at"); d.["ended_at"] <- match v with Some s -> box s | None -> null)
        patch.time_limit_minutes |> Option.iter (fun v -> sets.Add("time_limit_minutes = @time_limit_minutes"); d.["time_limit_minutes"] <- box v)
        patch.tournament_id |> Option.iter (fun v -> sets.Add("tournament_id = @tournament_id"); d.["tournament_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE tournament_rounds SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM tournament_rounds WHERE id = @id"
        conn.Execute(sql, {| id = id |})
