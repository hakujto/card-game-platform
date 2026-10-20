module cards_project.players.AchievementTypes

open System.Data

type AchievementRarity =
    | Common
    | Uncommon
    | Rare
    | Epic
    | Legendary

    static member ToString = function
        | Common -> "Common"
        | Uncommon -> "Uncommon"
        | Rare -> "Rare"
        | Epic -> "Epic"
        | Legendary -> "Legendary"

    static member FromString s =
        match s with
        | "Common" -> Common
        | "Uncommon" -> Uncommon
        | "Rare" -> Rare
        | "Epic" -> Epic
        | "Legendary" -> Legendary
        | _ -> failwithf "Unknown AchievementRarity: %s" s

[<CLIMutable>]
type AchievementRow = {
    Id: int64
    Name: string
    Description: string
    IconUrl: string option
    Points: int
    Rarity: string
    IsHidden: bool
    CreatedAt: string
    UpdatedAt: string
}

type AchievementDto = {
    id: int64
    name: string
    description: string
    icon_url: string option
    points: int
    rarity: string
    is_hidden: bool
    created_at: string
    updated_at: string
}

let achievementToDto (r: AchievementRow) : AchievementDto = {
    id = r.Id
    name = r.Name
    description = r.Description
    icon_url = r.IconUrl
    points = r.Points
    rarity = r.Rarity
    is_hidden = r.IsHidden
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type AchievementCreateRequest = {
    name: string
    description: string
    icon_url: string option
    points: int
    rarity: string
    is_hidden: bool
}

type AchievementUpdateRequest = {
    name: string option
    description: string option
    icon_url: string option option
    points: int option
    rarity: string option
    is_hidden: bool option
}

module AchievementDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements"
        conn.Query<AchievementRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements WHERE name LIKE @q OR description LIKE @q"
        conn.Query<AchievementRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements WHERE id = @id"
        conn.QueryFirstOrDefault<AchievementRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: AchievementCreateRequest) =
        let sql = "INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES (@name, @description, @icon_url, @points, @rarity, @is_hidden); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["name"] <- box dto.name
        p.["description"] <- box dto.description
        p.["icon_url"] <- match dto.icon_url with Some v -> box v | None -> null
        p.["points"] <- box dto.points
        p.["rarity"] <- box dto.rarity
        p.["is_hidden"] <- box dto.is_hidden
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: AchievementCreateRequest) =
        let sql = "UPDATE achievements SET name = @name, description = @description, icon_url = @icon_url, points = @points, rarity = @rarity, is_hidden = @is_hidden, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["name"] <- box dto.name
        p.["description"] <- box dto.description
        p.["icon_url"] <- match dto.icon_url with Some v -> box v | None -> null
        p.["points"] <- box dto.points
        p.["rarity"] <- box dto.rarity
        p.["is_hidden"] <- box dto.is_hidden
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: AchievementUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- box v)
        patch.icon_url |> Option.iter (fun v -> sets.Add("icon_url = @icon_url"); d.["icon_url"] <- match v with Some s -> box s | None -> null)
        patch.points |> Option.iter (fun v -> sets.Add("points = @points"); d.["points"] <- box v)
        patch.rarity |> Option.iter (fun v -> sets.Add("rarity = @rarity"); d.["rarity"] <- box v)
        patch.is_hidden |> Option.iter (fun v -> sets.Add("is_hidden = @is_hidden"); d.["is_hidden"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE achievements SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM achievements WHERE id = @id"
        conn.Execute(sql, {| id = id |})
