module cards_project.tournaments.SeasonTypes

open System.Data

type SeasonFormat =
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
        | _ -> failwithf "Unknown SeasonFormat: %s" s

[<CLIMutable>]
type SeasonRow = {
    Id: int64
    Name: string
    StartDate: string
    EndDate: string
    Format: string
    IsActive: bool
    RewardDescription: string option
    CreatedAt: string
    UpdatedAt: string
}

type SeasonDto = {
    id: int64
    name: string
    start_date: string
    end_date: string
    format: string
    is_active: bool
    reward_description: string option
    created_at: string
    updated_at: string
}

let seasonToDto (r: SeasonRow) : SeasonDto = {
    id = r.Id
    name = r.Name
    start_date = r.StartDate
    end_date = r.EndDate
    format = r.Format
    is_active = r.IsActive
    reward_description = r.RewardDescription
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type SeasonCreateRequest = {
    name: string
    start_date: string
    end_date: string
    format: string
    is_active: bool
    reward_description: string option
}

type SeasonUpdateRequest = {
    name: string option
    start_date: string option
    end_date: string option
    format: string option
    is_active: bool option
    reward_description: string option option
}

module SeasonDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons"
        conn.Query<SeasonRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons WHERE name LIKE @q"
        conn.Query<SeasonRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons WHERE id = @id"
        conn.QueryFirstOrDefault<SeasonRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: SeasonCreateRequest) =
        let sql = "INSERT INTO seasons (name, start_date, end_date, format, is_active, reward_description) VALUES (@name, @start_date, @end_date, @format, @is_active, @reward_description); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["name"] <- box dto.name
        p.["start_date"] <- box dto.start_date
        p.["end_date"] <- box dto.end_date
        p.["format"] <- box dto.format
        p.["is_active"] <- box dto.is_active
        p.["reward_description"] <- match dto.reward_description with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: SeasonCreateRequest) =
        let sql = "UPDATE seasons SET name = @name, start_date = @start_date, end_date = @end_date, format = @format, is_active = @is_active, reward_description = @reward_description, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["name"] <- box dto.name
        p.["start_date"] <- box dto.start_date
        p.["end_date"] <- box dto.end_date
        p.["format"] <- box dto.format
        p.["is_active"] <- box dto.is_active
        p.["reward_description"] <- match dto.reward_description with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: SeasonUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.start_date |> Option.iter (fun v -> sets.Add("start_date = @start_date"); d.["start_date"] <- box v)
        patch.end_date |> Option.iter (fun v -> sets.Add("end_date = @end_date"); d.["end_date"] <- box v)
        patch.format |> Option.iter (fun v -> sets.Add("format = @format"); d.["format"] <- box v)
        patch.is_active |> Option.iter (fun v -> sets.Add("is_active = @is_active"); d.["is_active"] <- box v)
        patch.reward_description |> Option.iter (fun v -> sets.Add("reward_description = @reward_description"); d.["reward_description"] <- match v with Some s -> box s | None -> null)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE seasons SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM seasons WHERE id = @id"
        conn.Execute(sql, {| id = id |})
