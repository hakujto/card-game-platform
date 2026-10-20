module cards_project.cards.DeckTagTypes

open System.Data

[<CLIMutable>]
type DeckTagRow = {
    Id: int64
    Name: string
    Slug: string option
    Color: string option
    CreatedAt: string
    UpdatedAt: string
}

type DeckTagDto = {
    id: int64
    name: string
    slug: string option
    color: string option
    created_at: string
    updated_at: string
}

let deck_tagToDto (r: DeckTagRow) : DeckTagDto = {
    id = r.Id
    name = r.Name
    slug = r.Slug
    color = r.Color
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DeckTagCreateRequest = {
    name: string
    slug: string option
    color: string option
}

type DeckTagUpdateRequest = {
    name: string option
    slug: string option option
    color: string option option
}

module DeckTagDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, slug, color, created_at, updated_at FROM deck_tags"
        conn.Query<DeckTagRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, slug, color, created_at, updated_at FROM deck_tags WHERE name LIKE @q"
        conn.Query<DeckTagRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, slug, color, created_at, updated_at FROM deck_tags WHERE id = @id"
        conn.QueryFirstOrDefault<DeckTagRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DeckTagCreateRequest) =
        let sql = "INSERT INTO deck_tags (name, slug, color) VALUES (@name, @slug, @color); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["name"] <- box dto.name
        p.["slug"] <- match dto.slug with Some v -> box v | None -> null
        p.["color"] <- match dto.color with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: DeckTagCreateRequest) =
        let sql = "UPDATE deck_tags SET name = @name, slug = @slug, color = @color, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["name"] <- box dto.name
        p.["slug"] <- match dto.slug with Some v -> box v | None -> null
        p.["color"] <- match dto.color with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: DeckTagUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.slug |> Option.iter (fun v -> sets.Add("slug = @slug"); d.["slug"] <- match v with Some s -> box s | None -> null)
        patch.color |> Option.iter (fun v -> sets.Add("color = @color"); d.["color"] <- match v with Some s -> box s | None -> null)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE deck_tags SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM deck_tags WHERE id = @id"
        conn.Execute(sql, {| id = id |})
