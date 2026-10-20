module cards_project.cards.DeckTypes

open System.Data

type DeckFormat =
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
        | _ -> failwithf "Unknown DeckFormat: %s" s

type DeckArchetype =
    | Aggro
    | Control
    | Midrange
    | Combo
    | Prison
    | Tempo

    static member ToString = function
        | Aggro -> "Aggro"
        | Control -> "Control"
        | Midrange -> "Midrange"
        | Combo -> "Combo"
        | Prison -> "Prison"
        | Tempo -> "Tempo"

    static member FromString s =
        match s with
        | "Aggro" -> Aggro
        | "Control" -> Control
        | "Midrange" -> Midrange
        | "Combo" -> Combo
        | "Prison" -> Prison
        | "Tempo" -> Tempo
        | _ -> failwithf "Unknown DeckArchetype: %s" s

[<CLIMutable>]
type DeckRow = {
    Id: int64
    Name: string
    Description: string option
    Format: string
    IsPublic: bool
    IsTournamentLegal: bool
    Archetype: string option
    Wins: int
    Losses: int
    Draws: int
    PlayerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DeckDto = {
    id: int64
    name: string
    description: string option
    format: string
    is_public: bool
    is_tournament_legal: bool
    archetype: string option
    wins: int
    losses: int
    draws: int
    player_id: int64
    created_at: string
    updated_at: string
}

let deckToDto (r: DeckRow) : DeckDto = {
    id = r.Id
    name = r.Name
    description = r.Description
    format = r.Format
    is_public = r.IsPublic
    is_tournament_legal = r.IsTournamentLegal
    archetype = r.Archetype
    wins = r.Wins
    losses = r.Losses
    draws = r.Draws
    player_id = r.PlayerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DeckCreateRequest = {
    name: string
    description: string option
    format: string
    is_public: bool
    is_tournament_legal: bool
    archetype: string option
    wins: int
    losses: int
    draws: int
    player_id: int64
}

type DeckUpdateRequest = {
    format: string option
    is_public: bool option
    is_tournament_legal: bool option
    player_id: int64 option
}

type DeckPatchRequest = {
    name: string option
    description: string option option
    format: string option
    is_public: bool option
    is_tournament_legal: bool option
    archetype: string option option
    player_id: int64 option
}

module DeckDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at FROM decks"
        conn.Query<DeckRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at FROM decks WHERE name LIKE @q OR description LIKE @q"
        conn.Query<DeckRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at FROM decks WHERE id = @id"
        conn.QueryFirstOrDefault<DeckRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DeckCreateRequest) =
        let sql = "INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id) VALUES (@name, @description, @format, @is_public, @is_tournament_legal, @archetype, @wins, @losses, @draws, @player_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["name"] <- box dto.name
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["format"] <- box dto.format
        p.["is_public"] <- box dto.is_public
        p.["is_tournament_legal"] <- box dto.is_tournament_legal
        p.["archetype"] <- match dto.archetype with Some v -> box v | None -> null
        p.["wins"] <- box dto.wins
        p.["losses"] <- box dto.losses
        p.["draws"] <- box dto.draws
        p.["player_id"] <- box dto.player_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: DeckCreateRequest) =
        let sql = "UPDATE decks SET name = @name, description = @description, format = @format, is_public = @is_public, is_tournament_legal = @is_tournament_legal, archetype = @archetype, wins = @wins, losses = @losses, draws = @draws, player_id = @player_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["name"] <- box dto.name
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["format"] <- box dto.format
        p.["is_public"] <- box dto.is_public
        p.["is_tournament_legal"] <- box dto.is_tournament_legal
        p.["archetype"] <- match dto.archetype with Some v -> box v | None -> null
        p.["wins"] <- box dto.wins
        p.["losses"] <- box dto.losses
        p.["draws"] <- box dto.draws
        p.["player_id"] <- box dto.player_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: DeckPatchRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- match v with Some s -> box s | None -> null)
        patch.format |> Option.iter (fun v -> sets.Add("format = @format"); d.["format"] <- box v)
        patch.is_public |> Option.iter (fun v -> sets.Add("is_public = @is_public"); d.["is_public"] <- box v)
        patch.is_tournament_legal |> Option.iter (fun v -> sets.Add("is_tournament_legal = @is_tournament_legal"); d.["is_tournament_legal"] <- box v)
        patch.archetype |> Option.iter (fun v -> sets.Add("archetype = @archetype"); d.["archetype"] <- match v with Some s -> box s | None -> null)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE decks SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM decks WHERE id = @id"
        conn.Execute(sql, {| id = id |})
