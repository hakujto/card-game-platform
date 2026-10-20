module cards_project.content.ArticleTagAssignmentTypes

open System.Data

[<CLIMutable>]
type ArticleTagAssignmentRow = {
    Id: int64
    ArticleId: int64
    TagId: int64
    CreatedAt: string
    UpdatedAt: string
}

type ArticleTagAssignmentDto = {
    id: int64
    article_id: int64
    tag_id: int64
    created_at: string
    updated_at: string
}

let article_tag_assignmentToDto (r: ArticleTagAssignmentRow) : ArticleTagAssignmentDto = {
    id = r.Id
    article_id = r.ArticleId
    tag_id = r.TagId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type ArticleTagAssignmentCreateRequest = {
    article_id: int64
    tag_id: int64
}

type ArticleTagAssignmentUpdateRequest = {
    article_id: int64 option
    tag_id: int64 option
}

module ArticleTagAssignmentDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, article_id, tag_id, created_at, updated_at FROM article_tag_assignments"
        conn.Query<ArticleTagAssignmentRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, article_id, tag_id, created_at, updated_at FROM article_tag_assignments WHERE id = @id"
        conn.QueryFirstOrDefault<ArticleTagAssignmentRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: ArticleTagAssignmentCreateRequest) =
        let sql = "INSERT INTO article_tag_assignments (article_id, tag_id) VALUES (@article_id, @tag_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: ArticleTagAssignmentCreateRequest) =
        let sql = "UPDATE article_tag_assignments SET article_id = @article_id, tag_id = @tag_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: ArticleTagAssignmentUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.article_id |> Option.iter (fun v -> sets.Add("article_id = @article_id"); d.["article_id"] <- box v)
        patch.tag_id |> Option.iter (fun v -> sets.Add("tag_id = @tag_id"); d.["tag_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE article_tag_assignments SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM article_tag_assignments WHERE id = @id"
        conn.Execute(sql, {| id = id |})
