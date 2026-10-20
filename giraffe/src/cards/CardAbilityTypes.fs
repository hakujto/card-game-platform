module cards_project.cards.CardAbilityTypes

open System.Data

type CardAbilityAbilityType =
    | Keyword
    | Activated
    | Triggered
    | Static

    static member ToString = function
        | Keyword -> "Keyword"
        | Activated -> "Activated"
        | Triggered -> "Triggered"
        | Static -> "Static"

    static member FromString s =
        match s with
        | "Keyword" -> Keyword
        | "Activated" -> Activated
        | "Triggered" -> Triggered
        | "Static" -> Static
        | _ -> failwithf "Unknown CardAbilityAbilityType: %s" s

type CardAbilityTiming =
    | Any
    | Sorcery
    | Instant
    | Combat

    static member ToString = function
        | Any -> "Any"
        | Sorcery -> "Sorcery"
        | Instant -> "Instant"
        | Combat -> "Combat"

    static member FromString s =
        match s with
        | "Any" -> Any
        | "Sorcery" -> Sorcery
        | "Instant" -> Instant
        | "Combat" -> Combat
        | _ -> failwithf "Unknown CardAbilityTiming: %s" s

[<CLIMutable>]
type CardAbilityRow = {
    Id: int64
    AbilityType: string
    Keyword: string option
    AbilityText: string
    Timing: string option
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type CardAbilityDto = {
    id: int64
    ability_type: string
    keyword: string option
    ability_text: string
    timing: string option
    card_id: int64
    created_at: string
    updated_at: string
}

let card_abilityToDto (r: CardAbilityRow) : CardAbilityDto = {
    id = r.Id
    ability_type = r.AbilityType
    keyword = r.Keyword
    ability_text = r.AbilityText
    timing = r.Timing
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CardAbilityCreateRequest = {
    ability_type: string
    keyword: string option
    ability_text: string
    timing: string option
    card_id: int64
}

type CardAbilityUpdateRequest = {
    ability_type: string option
    keyword: string option option
    ability_text: string option
    timing: string option option
    card_id: int64 option
}

module CardAbilityDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities"
        conn.Query<CardAbilityRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities WHERE keyword LIKE @q OR ability_text LIKE @q"
        conn.Query<CardAbilityRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities WHERE id = @id"
        conn.QueryFirstOrDefault<CardAbilityRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CardAbilityCreateRequest) =
        let sql = "INSERT INTO card_abilities (ability_type, keyword, ability_text, timing, card_id) VALUES (@ability_type, @keyword, @ability_text, @timing, @card_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["ability_type"] <- box dto.ability_type
        p.["keyword"] <- match dto.keyword with Some v -> box v | None -> null
        p.["ability_text"] <- box dto.ability_text
        p.["timing"] <- match dto.timing with Some v -> box v | None -> null
        p.["card_id"] <- box dto.card_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: CardAbilityCreateRequest) =
        let sql = "UPDATE card_abilities SET ability_type = @ability_type, keyword = @keyword, ability_text = @ability_text, timing = @timing, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["ability_type"] <- box dto.ability_type
        p.["keyword"] <- match dto.keyword with Some v -> box v | None -> null
        p.["ability_text"] <- box dto.ability_text
        p.["timing"] <- match dto.timing with Some v -> box v | None -> null
        p.["card_id"] <- box dto.card_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: CardAbilityUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.ability_type |> Option.iter (fun v -> sets.Add("ability_type = @ability_type"); d.["ability_type"] <- box v)
        patch.keyword |> Option.iter (fun v -> sets.Add("keyword = @keyword"); d.["keyword"] <- match v with Some s -> box s | None -> null)
        patch.ability_text |> Option.iter (fun v -> sets.Add("ability_text = @ability_text"); d.["ability_text"] <- box v)
        patch.timing |> Option.iter (fun v -> sets.Add("timing = @timing"); d.["timing"] <- match v with Some s -> box s | None -> null)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE card_abilities SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM card_abilities WHERE id = @id"
        conn.Execute(sql, {| id = id |})
