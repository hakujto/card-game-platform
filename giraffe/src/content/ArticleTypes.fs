module cards_project.content.ArticleTypes

open System.Data

type ArticleStatus =
    | Draft
    | Published
    | Archived

    static member ToString = function
        | Draft -> "Draft"
        | Published -> "Published"
        | Archived -> "Archived"

    static member FromString s =
        match s with
        | "Draft" -> Draft
        | "Published" -> Published
        | "Archived" -> Archived
        | _ -> failwithf "Unknown ArticleStatus: %s" s

type ArticleArticleType =
    | Guide
    | Tierlist
    | Matchup
    | News
    | Spotlight
    | Decklist

    static member ToString = function
        | Guide -> "Guide"
        | Tierlist -> "Tierlist"
        | Matchup -> "Matchup"
        | News -> "News"
        | Spotlight -> "Spotlight"
        | Decklist -> "Decklist"

    static member FromString s =
        match s with
        | "Guide" -> Guide
        | "Tierlist" -> Tierlist
        | "Matchup" -> Matchup
        | "News" -> News
        | "Spotlight" -> Spotlight
        | "Decklist" -> Decklist
        | _ -> failwithf "Unknown ArticleArticleType: %s" s

type ArticleLanguage =
    | EN
    | DE
    | FR
    | IT
    | ES
    | JP
    | PT

    static member ToString = function
        | EN -> "EN"
        | DE -> "DE"
        | FR -> "FR"
        | IT -> "IT"
        | ES -> "ES"
        | JP -> "JP"
        | PT -> "PT"

    static member FromString s =
        match s with
        | "EN" -> EN
        | "DE" -> DE
        | "FR" -> FR
        | "IT" -> IT
        | "ES" -> ES
        | "JP" -> JP
        | "PT" -> PT
        | _ -> failwithf "Unknown ArticleLanguage: %s" s

[<CLIMutable>]
type ArticleRow = {
    Id: int64
    Title: string
    Slug: string
    Body: string
    Excerpt: string option
    CoverImageUrl: string option
    Status: string
    ArticleType: string
    Language: string
    ViewCount: int
    LikesCount: int
    TotalViewsAlltime: int64
    IsFeatured: bool
    PublishedAt: string option
    AuthorId: int64
    FeaturedDeckId: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type ArticleDto = {
    id: int64
    title: string
    slug: string
    body: string
    excerpt: string option
    cover_image_url: string option
    status: string
    article_type: string
    language: string
    view_count: int
    likes_count: int
    total_views_alltime: int64
    is_featured: bool
    publishedAt: string option
    author_id: int64
    featured_deck_id: int64 option
    created_at: string
    updated_at: string
}

let articleToDto (r: ArticleRow) : ArticleDto = {
    id = r.Id
    title = r.Title
    slug = r.Slug
    body = r.Body
    excerpt = r.Excerpt
    cover_image_url = r.CoverImageUrl
    status = r.Status
    article_type = r.ArticleType
    language = r.Language
    view_count = r.ViewCount
    likes_count = r.LikesCount
    total_views_alltime = r.TotalViewsAlltime
    is_featured = r.IsFeatured
    publishedAt = r.PublishedAt
    author_id = r.AuthorId
    featured_deck_id = r.FeaturedDeckId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type ArticleCreateRequest = {
    title: string
    slug: string
    body: string
    excerpt: string option
    cover_image_url: string option
    status: string
    article_type: string
    language: string
    view_count: int
    likes_count: int
    total_views_alltime: int64
    is_featured: bool
    published_at: string option
    author_id: int64
    featured_deck_id: int64 option
}

type ArticleUpdateRequest = {
    title: string option
    slug: string option
    body: string option
    article_type: string option
    language: string option
    total_views_alltime: int64 option
    published_at: string option option
    author_id: int64 option
    featured_deck_id: int64 option
}

type ArticlePatchRequest = {
    title: string option
    slug: string option
    body: string option
    excerpt: string option option
    cover_image_url: string option option
    article_type: string option
    language: string option
    total_views_alltime: int64 option
    is_featured: bool option
    published_at: string option option
    author_id: int64 option
    featured_deck_id: int64 option
}

module ArticleDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles"
        conn.Query<ArticleRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles WHERE title LIKE @q OR excerpt LIKE @q"
        conn.Query<ArticleRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles WHERE id = @id"
        conn.QueryFirstOrDefault<ArticleRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: ArticleCreateRequest) =
        let sql = "INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id) VALUES (@title, @slug, @body, @excerpt, @cover_image_url, @status, @article_type, @language, @view_count, @likes_count, @total_views_alltime, @is_featured, @published_at, @author_id, @featured_deck_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["title"] <- box dto.title
        p.["slug"] <- box dto.slug
        p.["body"] <- box dto.body
        p.["excerpt"] <- match dto.excerpt with Some v -> box v | None -> null
        p.["cover_image_url"] <- match dto.cover_image_url with Some v -> box v | None -> null
        p.["status"] <- box dto.status
        p.["article_type"] <- box dto.article_type
        p.["language"] <- box dto.language
        p.["view_count"] <- box dto.view_count
        p.["likes_count"] <- box dto.likes_count
        p.["total_views_alltime"] <- box dto.total_views_alltime
        p.["is_featured"] <- box dto.is_featured
        p.["published_at"] <- match dto.published_at with Some v -> box v | None -> null
        p.["author_id"] <- box dto.author_id
        p.["featured_deck_id"] <- match dto.featured_deck_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: ArticleCreateRequest) =
        let sql = "UPDATE articles SET title = @title, slug = @slug, body = @body, excerpt = @excerpt, cover_image_url = @cover_image_url, status = @status, article_type = @article_type, language = @language, view_count = @view_count, likes_count = @likes_count, total_views_alltime = @total_views_alltime, is_featured = @is_featured, published_at = @published_at, author_id = @author_id, featured_deck_id = @featured_deck_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["title"] <- box dto.title
        p.["slug"] <- box dto.slug
        p.["body"] <- box dto.body
        p.["excerpt"] <- match dto.excerpt with Some v -> box v | None -> null
        p.["cover_image_url"] <- match dto.cover_image_url with Some v -> box v | None -> null
        p.["status"] <- box dto.status
        p.["article_type"] <- box dto.article_type
        p.["language"] <- box dto.language
        p.["view_count"] <- box dto.view_count
        p.["likes_count"] <- box dto.likes_count
        p.["total_views_alltime"] <- box dto.total_views_alltime
        p.["is_featured"] <- box dto.is_featured
        p.["published_at"] <- match dto.published_at with Some v -> box v | None -> null
        p.["author_id"] <- box dto.author_id
        p.["featured_deck_id"] <- match dto.featured_deck_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: ArticlePatchRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.title |> Option.iter (fun v -> sets.Add("title = @title"); d.["title"] <- box v)
        patch.slug |> Option.iter (fun v -> sets.Add("slug = @slug"); d.["slug"] <- box v)
        patch.body |> Option.iter (fun v -> sets.Add("body = @body"); d.["body"] <- box v)
        patch.excerpt |> Option.iter (fun v -> sets.Add("excerpt = @excerpt"); d.["excerpt"] <- match v with Some s -> box s | None -> null)
        patch.cover_image_url |> Option.iter (fun v -> sets.Add("cover_image_url = @cover_image_url"); d.["cover_image_url"] <- match v with Some s -> box s | None -> null)
        patch.article_type |> Option.iter (fun v -> sets.Add("article_type = @article_type"); d.["article_type"] <- box v)
        patch.language |> Option.iter (fun v -> sets.Add("language = @language"); d.["language"] <- box v)
        patch.total_views_alltime |> Option.iter (fun v -> sets.Add("total_views_alltime = @total_views_alltime"); d.["total_views_alltime"] <- box v)
        patch.is_featured |> Option.iter (fun v -> sets.Add("is_featured = @is_featured"); d.["is_featured"] <- box v)
        patch.published_at |> Option.iter (fun v -> sets.Add("published_at = @published_at"); d.["published_at"] <- match v with Some s -> box s | None -> null)
        patch.author_id |> Option.iter (fun v -> sets.Add("author_id = @author_id"); d.["author_id"] <- box v)
        patch.featured_deck_id |> Option.iter (fun v -> sets.Add("featured_deck_id = @featured_deck_id"); d.["featured_deck_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE articles SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM articles WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE articles SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
