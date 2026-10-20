module cards_project.tournaments.GameTypes

open System.Data

type GameWinnerSide =
    | Player1
    | Player2
    | Draw

    static member ToString = function
        | Player1 -> "Player1"
        | Player2 -> "Player2"
        | Draw -> "Draw"

    static member FromString s =
        match s with
        | "Player1" -> Player1
        | "Player2" -> Player2
        | "Draw" -> Draw
        | _ -> failwithf "Unknown GameWinnerSide: %s" s

type GameEndedBy =
    | Normal
    | Timeout
    | Concession
    | DrawOffer

    static member ToString = function
        | Normal -> "Normal"
        | Timeout -> "Timeout"
        | Concession -> "Concession"
        | DrawOffer -> "DrawOffer"

    static member FromString s =
        match s with
        | "Normal" -> Normal
        | "Timeout" -> Timeout
        | "Concession" -> Concession
        | "DrawOffer" -> DrawOffer
        | _ -> failwithf "Unknown GameEndedBy: %s" s

[<CLIMutable>]
type GameRow = {
    Id: int64
    GameNumber: int
    WinnerSide: string option
    ComplexityScore: float option
    TurnsPlayed: int64 option
    DurationSeconds: int64 option
    EndedBy: string option
    ReplayUrl: string option
    MatchId: int64
    WinnerId: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type GameDto = {
    id: int64
    game_number: int
    winner_side: string option
    complexity_score: float option
    turns_played: int option
    duration_seconds: int option
    ended_by: string option
    replay_url: string option
    match_id: int64
    winner_id: int64 option
    created_at: string
    updated_at: string
}

let gameToDto (r: GameRow) : GameDto = {
    id = r.Id
    game_number = r.GameNumber
    winner_side = r.WinnerSide
    complexity_score = r.ComplexityScore
    turns_played = r.TurnsPlayed |> Option.map int
    duration_seconds = r.DurationSeconds |> Option.map int
    ended_by = r.EndedBy
    replay_url = r.ReplayUrl
    match_id = r.MatchId
    winner_id = r.WinnerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type GameCreateRequest = {
    game_number: int
    winner_side: string option
    complexity_score: float option
    turns_played: int option
    duration_seconds: int option
    ended_by: string option
    replay_url: string option
    match_id: int64
    winner_id: int64 option
}

type GameUpdateRequest = {
    game_number: int option
    winner_side: string option option
    complexity_score: float option option
    turns_played: int option option
    duration_seconds: int option option
    ended_by: string option option
    replay_url: string option option
    match_id: int64 option
    winner_id: int64 option
}

module GameDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at FROM games"
        conn.Query<GameRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at FROM games WHERE id = @id"
        conn.QueryFirstOrDefault<GameRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: GameCreateRequest) =
        let sql = "INSERT INTO games (game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id) VALUES (@game_number, @winner_side, @complexity_score, @turns_played, @duration_seconds, @ended_by, @replay_url, @match_id, @winner_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["game_number"] <- box dto.game_number
        p.["winner_side"] <- match dto.winner_side with Some v -> box v | None -> null
        p.["complexity_score"] <- match dto.complexity_score with Some v -> box v | None -> null
        p.["turns_played"] <- match dto.turns_played with Some v -> box v | None -> null
        p.["duration_seconds"] <- match dto.duration_seconds with Some v -> box v | None -> null
        p.["ended_by"] <- match dto.ended_by with Some v -> box v | None -> null
        p.["replay_url"] <- match dto.replay_url with Some v -> box v | None -> null
        p.["match_id"] <- box dto.match_id
        p.["winner_id"] <- match dto.winner_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: GameCreateRequest) =
        let sql = "UPDATE games SET game_number = @game_number, winner_side = @winner_side, complexity_score = @complexity_score, turns_played = @turns_played, duration_seconds = @duration_seconds, ended_by = @ended_by, replay_url = @replay_url, match_id = @match_id, winner_id = @winner_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["game_number"] <- box dto.game_number
        p.["winner_side"] <- match dto.winner_side with Some v -> box v | None -> null
        p.["complexity_score"] <- match dto.complexity_score with Some v -> box v | None -> null
        p.["turns_played"] <- match dto.turns_played with Some v -> box v | None -> null
        p.["duration_seconds"] <- match dto.duration_seconds with Some v -> box v | None -> null
        p.["ended_by"] <- match dto.ended_by with Some v -> box v | None -> null
        p.["replay_url"] <- match dto.replay_url with Some v -> box v | None -> null
        p.["match_id"] <- box dto.match_id
        p.["winner_id"] <- match dto.winner_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: GameUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.game_number |> Option.iter (fun v -> sets.Add("game_number = @game_number"); d.["game_number"] <- box v)
        patch.winner_side |> Option.iter (fun v -> sets.Add("winner_side = @winner_side"); d.["winner_side"] <- match v with Some s -> box s | None -> null)
        patch.complexity_score |> Option.iter (fun v -> sets.Add("complexity_score = @complexity_score"); d.["complexity_score"] <- match v with Some s -> box s | None -> null)
        patch.turns_played |> Option.iter (fun v -> sets.Add("turns_played = @turns_played"); d.["turns_played"] <- match v with Some s -> box s | None -> null)
        patch.duration_seconds |> Option.iter (fun v -> sets.Add("duration_seconds = @duration_seconds"); d.["duration_seconds"] <- match v with Some s -> box s | None -> null)
        patch.ended_by |> Option.iter (fun v -> sets.Add("ended_by = @ended_by"); d.["ended_by"] <- match v with Some s -> box s | None -> null)
        patch.replay_url |> Option.iter (fun v -> sets.Add("replay_url = @replay_url"); d.["replay_url"] <- match v with Some s -> box s | None -> null)
        patch.match_id |> Option.iter (fun v -> sets.Add("match_id = @match_id"); d.["match_id"] <- box v)
        patch.winner_id |> Option.iter (fun v -> sets.Add("winner_id = @winner_id"); d.["winner_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE games SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM games WHERE id = @id"
        conn.Execute(sql, {| id = id |})
