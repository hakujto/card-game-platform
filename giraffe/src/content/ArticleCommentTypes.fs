module cards_project.content.ArticleCommentTypes

open System.Data

[<CLIMutable>]
type ArticleCommentRow = {
    Id: int64
    Body: string
    IsHidden: bool
    ArticleId: int64
    AuthorId: int64
    ParentCommentId: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type ArticleCommentDto = {
    id: int64
    body: string
    is_hidden: bool
    article_id: int64
    author_id: int64
    parent_comment_id: int64 option
    created_at: string
    updated_at: string
}

let article_commentToDto (r: ArticleCommentRow) : ArticleCommentDto = {
    id = r.Id
    body = r.Body
    is_hidden = r.IsHidden
    article_id = r.ArticleId
    author_id = r.AuthorId
    parent_comment_id = r.ParentCommentId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type ArticleCommentCreateRequest = {
    body: string
    is_hidden: bool
    article_id: int64
    author_id: int64
    parent_comment_id: int64 option
}

type ArticleCommentUpdateRequest = {
    body: string option
    is_hidden: bool option
    article_id: int64 option
    author_id: int64 option
    parent_comment_id: int64 option
}

module ArticleCommentDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at FROM article_comments"
        conn.Query<ArticleCommentRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at FROM article_comments WHERE id = @id"
        conn.QueryFirstOrDefault<ArticleCommentRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: ArticleCommentCreateRequest) =
        let sql = "INSERT INTO article_comments (body, is_hidden, article_id, author_id, parent_comment_id) VALUES (@body, @is_hidden, @article_id, @author_id, @parent_comment_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["body"] <- box dto.body
        p.["is_hidden"] <- box dto.is_hidden
        p.["article_id"] <- box dto.article_id
        p.["author_id"] <- box dto.author_id
        p.["parent_comment_id"] <- match dto.parent_comment_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: ArticleCommentCreateRequest) =
        let sql = "UPDATE article_comments SET body = @body, is_hidden = @is_hidden, article_id = @article_id, author_id = @author_id, parent_comment_id = @parent_comment_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["body"] <- box dto.body
        p.["is_hidden"] <- box dto.is_hidden
        p.["article_id"] <- box dto.article_id
        p.["author_id"] <- box dto.author_id
        p.["parent_comment_id"] <- match dto.parent_comment_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: ArticleCommentUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.body |> Option.iter (fun v -> sets.Add("body = @body"); d.["body"] <- box v)
        patch.is_hidden |> Option.iter (fun v -> sets.Add("is_hidden = @is_hidden"); d.["is_hidden"] <- box v)
        patch.article_id |> Option.iter (fun v -> sets.Add("article_id = @article_id"); d.["article_id"] <- box v)
        patch.author_id |> Option.iter (fun v -> sets.Add("author_id = @author_id"); d.["author_id"] <- box v)
        patch.parent_comment_id |> Option.iter (fun v -> sets.Add("parent_comment_id = @parent_comment_id"); d.["parent_comment_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE article_comments SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM article_comments WHERE id = @id"
        conn.Execute(sql, {| id = id |})
