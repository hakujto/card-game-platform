module cards_project.tournaments.TournamentRegistrationTypes

open System.Data

type TournamentRegistrationStatus =
    | Registered
    | Waitlisted
    | Withdrawn
    | Disqualified

    static member ToString = function
        | Registered -> "Registered"
        | Waitlisted -> "Waitlisted"
        | Withdrawn -> "Withdrawn"
        | Disqualified -> "Disqualified"

    static member FromString s =
        match s with
        | "Registered" -> Registered
        | "Waitlisted" -> Waitlisted
        | "Withdrawn" -> Withdrawn
        | "Disqualified" -> Disqualified
        | _ -> failwithf "Unknown TournamentRegistrationStatus: %s" s

[<CLIMutable>]
type TournamentRegistrationRow = {
    Id: int64
    Status: string
    Seed: int64 option
    FinalStanding: int64 option
    PointsEarned: int
    RegisteredAt: string
    TournamentId: int64
    PlayerId: int64
    DeckId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TournamentRegistrationDto = {
    id: int64
    status: string
    seed: int option
    final_standing: int option
    points_earned: int
    registeredAt: string
    tournament_id: int64
    player_id: int64
    deck_id: int64
    created_at: string
    updated_at: string
}

let tournament_registrationToDto (r: TournamentRegistrationRow) : TournamentRegistrationDto = {
    id = r.Id
    status = r.Status
    seed = r.Seed |> Option.map int
    final_standing = r.FinalStanding |> Option.map int
    points_earned = r.PointsEarned
    registeredAt = r.RegisteredAt
    tournament_id = r.TournamentId
    player_id = r.PlayerId
    deck_id = r.DeckId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TournamentRegistrationCreateRequest = {
    status: string
    seed: int option
    final_standing: int option
    points_earned: int
    registered_at: string
    tournament_id: int64
    player_id: int64
    deck_id: int64
}

type TournamentRegistrationUpdateRequest = {
    status: string option
    seed: int option option
    final_standing: int option option
    points_earned: int option
    registered_at: string option
    tournament_id: int64 option
    player_id: int64 option
    deck_id: int64 option
}

module TournamentRegistrationDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at FROM tournament_registrations"
        conn.Query<TournamentRegistrationRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at FROM tournament_registrations WHERE id = @id"
        conn.QueryFirstOrDefault<TournamentRegistrationRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TournamentRegistrationCreateRequest) =
        let sql = "INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES (@status, @seed, @final_standing, @points_earned, @registered_at, @tournament_id, @player_id, @deck_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["status"] <- box dto.status
        p.["seed"] <- match dto.seed with Some v -> box v | None -> null
        p.["final_standing"] <- match dto.final_standing with Some v -> box v | None -> null
        p.["points_earned"] <- box dto.points_earned
        p.["registered_at"] <- box dto.registered_at
        p.["tournament_id"] <- box dto.tournament_id
        p.["player_id"] <- box dto.player_id
        p.["deck_id"] <- box dto.deck_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TournamentRegistrationCreateRequest) =
        let sql = "UPDATE tournament_registrations SET status = @status, seed = @seed, final_standing = @final_standing, points_earned = @points_earned, registered_at = @registered_at, tournament_id = @tournament_id, player_id = @player_id, deck_id = @deck_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["status"] <- box dto.status
        p.["seed"] <- match dto.seed with Some v -> box v | None -> null
        p.["final_standing"] <- match dto.final_standing with Some v -> box v | None -> null
        p.["points_earned"] <- box dto.points_earned
        p.["registered_at"] <- box dto.registered_at
        p.["tournament_id"] <- box dto.tournament_id
        p.["player_id"] <- box dto.player_id
        p.["deck_id"] <- box dto.deck_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TournamentRegistrationUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.seed |> Option.iter (fun v -> sets.Add("seed = @seed"); d.["seed"] <- match v with Some s -> box s | None -> null)
        patch.final_standing |> Option.iter (fun v -> sets.Add("final_standing = @final_standing"); d.["final_standing"] <- match v with Some s -> box s | None -> null)
        patch.points_earned |> Option.iter (fun v -> sets.Add("points_earned = @points_earned"); d.["points_earned"] <- box v)
        patch.registered_at |> Option.iter (fun v -> sets.Add("registered_at = @registered_at"); d.["registered_at"] <- box v)
        patch.tournament_id |> Option.iter (fun v -> sets.Add("tournament_id = @tournament_id"); d.["tournament_id"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        patch.deck_id |> Option.iter (fun v -> sets.Add("deck_id = @deck_id"); d.["deck_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE tournament_registrations SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM tournament_registrations WHERE id = @id"
        conn.Execute(sql, {| id = id |})
