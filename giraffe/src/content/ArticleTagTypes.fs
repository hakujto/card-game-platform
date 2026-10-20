module cards_project.content.ArticleTagTypes

open System.Data

[<CLIMutable>]
type ArticleTagRow = {
    Id: int64
    Name: string
    Slug: string
    CreatedAt: string
    UpdatedAt: string
}

type ArticleTagDto = {
    id: int64
    name: string
    slug: string
    created_at: string
    updated_at: string
}

let article_tagToDto (r: ArticleTagRow) : ArticleTagDto = {
    id = r.Id
    name = r.Name
    slug = r.Slug
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type ArticleTagCreateRequest = {
    name: string
    slug: string
}

type ArticleTagUpdateRequest = {
    name: string option
    slug: string option
}

module ArticleTagDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, name, slug, created_at, updated_at FROM article_tags"
        conn.Query<ArticleTagRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, name, slug, created_at, updated_at FROM article_tags WHERE name LIKE @q"
        conn.Query<ArticleTagRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, name, slug, created_at, updated_at FROM article_tags WHERE id = @id"
        conn.QueryFirstOrDefault<ArticleTagRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: ArticleTagCreateRequest) =
        let sql = "INSERT INTO article_tags (name, slug) VALUES (@name, @slug); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: ArticleTagCreateRequest) =
        let sql = "UPDATE article_tags SET name = @name, slug = @slug, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: ArticleTagUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.slug |> Option.iter (fun v -> sets.Add("slug = @slug"); d.["slug"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE article_tags SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM article_tags WHERE id = @id"
        conn.Execute(sql, {| id = id |})
