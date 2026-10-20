module cards_project.cards.CardSetTypes

open System.Data

type CardSetSetType =
    | Core
    | Expansion
    | Supplemental
    | Masters
    | Draft

    static member ToString = function
        | Core -> "Core"
        | Expansion -> "Expansion"
        | Supplemental -> "Supplemental"
        | Masters -> "Masters"
        | Draft -> "Draft"

    static member FromString s =
        match s with
        | "Core" -> Core
        | "Expansion" -> Expansion
        | "Supplemental" -> Supplemental
        | "Masters" -> Masters
        | "Draft" -> Draft
        | _ -> failwithf "Unknown CardSetSetType: %s" s

[<CLIMutable>]
type CardSetRow = {
    Id: int64
    Name: string
    Code: string
    ReleaseDate: string
    RotationDate: string option
    SetType: string
    TotalCards: int
    IsRotated: bool
    Description: string option
    LogoUrl: string option
    CreatedAt: string
    UpdatedAt: string
}

type CardSetDto = {
    id: int64
    name: string
    code: string
    release_date: string
    rotation_date: string option
    set_type: string
    total_cards: int
    is_rotated: bool
    description: string option
    logo_url: string option
    created_at: string
    updated_at: string
}

let card_setToDto (r: CardSetRow) : CardSetDto = {
    id = r.Id
    name = r.Name
    code = r.Code
    release_date = r.ReleaseDate
    rotation_date = r.RotationDate
    set_type = r.SetType
    total_cards = r.TotalCards
    is_rotated = r.IsRotated
    description = r.Description
    logo_url = r.LogoUrl
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CardSetCreateRequest = {
    name: string
    code: string
    release_date: string
    rotation_date: string option
    set_type: string
    total_cards: int
    is_rotated: bool
    description: string option
    logo_url: string option
}

type CardSetUpdateRequest = {
    name: string option
    code: string option
    release_date: string option
    rotation_date: string option option
    set_type: string option
    total_cards: int option
    is_rotated: bool option
    description: string option option
    logo_url: string option option
}

module CardSetDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at FROM card_sets"
        conn.Query<CardSetRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at FROM card_sets WHERE name LIKE @q OR code LIKE @q"
        conn.Query<CardSetRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at FROM card_sets WHERE id = @id"
        conn.QueryFirstOrDefault<CardSetRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CardSetCreateRequest) =
        let sql = "INSERT INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url) VALUES (@name, @code, @release_date, @rotation_date, @set_type, @total_cards, @is_rotated, @description, @logo_url); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["name"] <- box dto.name
        p.["code"] <- box dto.code
        p.["release_date"] <- box dto.release_date
        p.["rotation_date"] <- match dto.rotation_date with Some v -> box v | None -> null
        p.["set_type"] <- box dto.set_type
        p.["total_cards"] <- box dto.total_cards
        p.["is_rotated"] <- box dto.is_rotated
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["logo_url"] <- match dto.logo_url with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: CardSetCreateRequest) =
        let sql = "UPDATE card_sets SET name = @name, code = @code, release_date = @release_date, rotation_date = @rotation_date, set_type = @set_type, total_cards = @total_cards, is_rotated = @is_rotated, description = @description, logo_url = @logo_url, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["name"] <- box dto.name
        p.["code"] <- box dto.code
        p.["release_date"] <- box dto.release_date
        p.["rotation_date"] <- match dto.rotation_date with Some v -> box v | None -> null
        p.["set_type"] <- box dto.set_type
        p.["total_cards"] <- box dto.total_cards
        p.["is_rotated"] <- box dto.is_rotated
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["logo_url"] <- match dto.logo_url with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: CardSetUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.code |> Option.iter (fun v -> sets.Add("code = @code"); d.["code"] <- box v)
        patch.release_date |> Option.iter (fun v -> sets.Add("release_date = @release_date"); d.["release_date"] <- box v)
        patch.rotation_date |> Option.iter (fun v -> sets.Add("rotation_date = @rotation_date"); d.["rotation_date"] <- match v with Some s -> box s | None -> null)
        patch.set_type |> Option.iter (fun v -> sets.Add("set_type = @set_type"); d.["set_type"] <- box v)
        patch.total_cards |> Option.iter (fun v -> sets.Add("total_cards = @total_cards"); d.["total_cards"] <- box v)
        patch.is_rotated |> Option.iter (fun v -> sets.Add("is_rotated = @is_rotated"); d.["is_rotated"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- match v with Some s -> box s | None -> null)
        patch.logo_url |> Option.iter (fun v -> sets.Add("logo_url = @logo_url"); d.["logo_url"] <- match v with Some s -> box s | None -> null)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE card_sets SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM card_sets WHERE id = @id"
        conn.Execute(sql, {| id = id |})
