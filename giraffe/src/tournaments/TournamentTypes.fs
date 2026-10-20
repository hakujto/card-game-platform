module cards_project.tournaments.TournamentTypes

open System.Data

type TournamentStatus =
    | Draft
    | Registration
    | Ongoing
    | Completed
    | Cancelled

    static member ToString = function
        | Draft -> "Draft"
        | Registration -> "Registration"
        | Ongoing -> "Ongoing"
        | Completed -> "Completed"
        | Cancelled -> "Cancelled"

    static member FromString s =
        match s with
        | "Draft" -> Draft
        | "Registration" -> Registration
        | "Ongoing" -> Ongoing
        | "Completed" -> Completed
        | "Cancelled" -> Cancelled
        | _ -> failwithf "Unknown TournamentStatus: %s" s

type TournamentFormat =
    | Standard
    | Extended
    | Legacy
    | Vintage
    | Commander
    | Draft

    static member ToString = function
        | Standard -> "Standard"
        | Extended -> "Extended"
        | Legacy -> "Legacy"
        | Vintage -> "Vintage"
        | Commander -> "Commander"
        | Draft -> "Draft"

    static member FromString s =
        match s with
        | "Standard" -> Standard
        | "Extended" -> Extended
        | "Legacy" -> Legacy
        | "Vintage" -> Vintage
        | "Commander" -> Commander
        | "Draft" -> Draft
        | _ -> failwithf "Unknown TournamentFormat: %s" s

type TournamentTournamentType =
    | Swiss
    | SingleElimination
    | DoubleElimination
    | RoundRobin

    static member ToString = function
        | Swiss -> "Swiss"
        | SingleElimination -> "SingleElimination"
        | DoubleElimination -> "DoubleElimination"
        | RoundRobin -> "RoundRobin"

    static member FromString s =
        match s with
        | "Swiss" -> Swiss
        | "SingleElimination" -> SingleElimination
        | "DoubleElimination" -> DoubleElimination
        | "RoundRobin" -> RoundRobin
        | _ -> failwithf "Unknown TournamentTournamentType: %s" s

[<CLIMutable>]
type TournamentRow = {
    Id: int64
    PublicId: string
    Name: string
    Description: string option
    Status: string
    BracketData: string option
    Format: string
    TournamentType: string
    MaxPlayers: int
    EntryFee: decimal
    PrizePool: decimal
    StartTime: string
    EndTime: string option
    IsOnline: bool
    Location: string option
    RulesText: string option
    SeasonId: int64
    OrganizerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TournamentDto = {
    id: int64
    public_id: string
    name: string
    description: string option
    status: string
    bracket_data: string option
    format: string
    tournament_type: string
    max_players: int
    entry_fee: decimal
    prize_pool: decimal
    startTime: string
    endTime: string option
    is_online: bool
    location: string option
    rules_text: string option
    season_id: int64
    organizer_id: int64
    created_at: string
    updated_at: string
}

let tournamentToDto (r: TournamentRow) : TournamentDto = {
    id = r.Id
    public_id = r.PublicId
    name = r.Name
    description = r.Description
    status = r.Status
    bracket_data = r.BracketData
    format = r.Format
    tournament_type = r.TournamentType
    max_players = r.MaxPlayers
    entry_fee = r.EntryFee
    prize_pool = r.PrizePool
    startTime = r.StartTime
    endTime = r.EndTime
    is_online = r.IsOnline
    location = r.Location
    rules_text = r.RulesText
    season_id = r.SeasonId
    organizer_id = r.OrganizerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TournamentCreateRequest = {
    public_id: string
    name: string
    description: string option
    status: string
    bracket_data: string option
    format: string
    tournament_type: string
    max_players: int
    entry_fee: decimal
    prize_pool: decimal
    start_time: string
    end_time: string option
    is_online: bool
    location: string option
    rules_text: string option
    season_id: int64
    organizer_id: int64
}

type TournamentUpdateRequest = {
    public_id: string option
    name: string option
    bracket_data: string option option
    format: string option
    tournament_type: string option
    max_players: int option
    entry_fee: decimal option
    prize_pool: decimal option
    start_time: string option
    end_time: string option option
    is_online: bool option
    season_id: int64 option
    organizer_id: int64 option
}

type TournamentPatchRequest = {
    public_id: string option
    name: string option
    description: string option option
    bracket_data: string option option
    format: string option
    tournament_type: string option
    max_players: int option
    entry_fee: decimal option
    prize_pool: decimal option
    start_time: string option
    end_time: string option option
    is_online: bool option
    location: string option option
    rules_text: string option option
    season_id: int64 option
    organizer_id: int64 option
}

// hook: after_update
let sync_season_stats (entity: TournamentRow) =
    // TODO: implement sync_season_stats hook
    entity

// hook: before_delete
let prevent_delete_if_ongoing (entity: TournamentRow) =
    // TODO: implement prevent_delete_if_ongoing hook
    entity

module TournamentDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments"
        conn.Query<TournamentRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments WHERE name LIKE @q OR description LIKE @q"
        conn.Query<TournamentRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments WHERE id = @id"
        conn.QueryFirstOrDefault<TournamentRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TournamentCreateRequest) =
        let sql = "INSERT INTO tournaments (public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id) VALUES (@public_id, @name, @description, @status, @bracket_data, @format, @tournament_type, @max_players, @entry_fee, @prize_pool, @start_time, @end_time, @is_online, @location, @rules_text, @season_id, @organizer_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["public_id"] <- box dto.public_id
        p.["name"] <- box dto.name
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["status"] <- box dto.status
        p.["bracket_data"] <- match dto.bracket_data with Some v -> box v | None -> null
        p.["format"] <- box dto.format
        p.["tournament_type"] <- box dto.tournament_type
        p.["max_players"] <- box dto.max_players
        p.["entry_fee"] <- box dto.entry_fee
        p.["prize_pool"] <- box dto.prize_pool
        p.["start_time"] <- box dto.start_time
        p.["end_time"] <- match dto.end_time with Some v -> box v | None -> null
        p.["is_online"] <- box dto.is_online
        p.["location"] <- match dto.location with Some v -> box v | None -> null
        p.["rules_text"] <- match dto.rules_text with Some v -> box v | None -> null
        p.["season_id"] <- box dto.season_id
        p.["organizer_id"] <- box dto.organizer_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TournamentCreateRequest) =
        let sql = "UPDATE tournaments SET public_id = @public_id, name = @name, description = @description, status = @status, bracket_data = @bracket_data, format = @format, tournament_type = @tournament_type, max_players = @max_players, entry_fee = @entry_fee, prize_pool = @prize_pool, start_time = @start_time, end_time = @end_time, is_online = @is_online, location = @location, rules_text = @rules_text, season_id = @season_id, organizer_id = @organizer_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["public_id"] <- box dto.public_id
        p.["name"] <- box dto.name
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["status"] <- box dto.status
        p.["bracket_data"] <- match dto.bracket_data with Some v -> box v | None -> null
        p.["format"] <- box dto.format
        p.["tournament_type"] <- box dto.tournament_type
        p.["max_players"] <- box dto.max_players
        p.["entry_fee"] <- box dto.entry_fee
        p.["prize_pool"] <- box dto.prize_pool
        p.["start_time"] <- box dto.start_time
        p.["end_time"] <- match dto.end_time with Some v -> box v | None -> null
        p.["is_online"] <- box dto.is_online
        p.["location"] <- match dto.location with Some v -> box v | None -> null
        p.["rules_text"] <- match dto.rules_text with Some v -> box v | None -> null
        p.["season_id"] <- box dto.season_id
        p.["organizer_id"] <- box dto.organizer_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TournamentPatchRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.public_id |> Option.iter (fun v -> sets.Add("public_id = @public_id"); d.["public_id"] <- box v)
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- match v with Some s -> box s | None -> null)
        patch.bracket_data |> Option.iter (fun v -> sets.Add("bracket_data = @bracket_data"); d.["bracket_data"] <- match v with Some s -> box s | None -> null)
        patch.format |> Option.iter (fun v -> sets.Add("format = @format"); d.["format"] <- box v)
        patch.tournament_type |> Option.iter (fun v -> sets.Add("tournament_type = @tournament_type"); d.["tournament_type"] <- box v)
        patch.max_players |> Option.iter (fun v -> sets.Add("max_players = @max_players"); d.["max_players"] <- box v)
        patch.entry_fee |> Option.iter (fun v -> sets.Add("entry_fee = @entry_fee"); d.["entry_fee"] <- box v)
        patch.prize_pool |> Option.iter (fun v -> sets.Add("prize_pool = @prize_pool"); d.["prize_pool"] <- box v)
        patch.start_time |> Option.iter (fun v -> sets.Add("start_time = @start_time"); d.["start_time"] <- box v)
        patch.end_time |> Option.iter (fun v -> sets.Add("end_time = @end_time"); d.["end_time"] <- match v with Some s -> box s | None -> null)
        patch.is_online |> Option.iter (fun v -> sets.Add("is_online = @is_online"); d.["is_online"] <- box v)
        patch.location |> Option.iter (fun v -> sets.Add("location = @location"); d.["location"] <- match v with Some s -> box s | None -> null)
        patch.rules_text |> Option.iter (fun v -> sets.Add("rules_text = @rules_text"); d.["rules_text"] <- match v with Some s -> box s | None -> null)
        patch.season_id |> Option.iter (fun v -> sets.Add("season_id = @season_id"); d.["season_id"] <- box v)
        patch.organizer_id |> Option.iter (fun v -> sets.Add("organizer_id = @organizer_id"); d.["organizer_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE tournaments SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM tournaments WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE tournaments SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
