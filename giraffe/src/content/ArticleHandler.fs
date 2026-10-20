module cards_project.content.ArticleHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.ArticleTypes

let validateArticle (r: ArticleCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.status = "Published")) || (r.published_at <> None))) then errors.Add("Published article must have a published_at timestamp")
    if not ((r.view_count >= 0)) then errors.Add("Article view count must not be negative")
    if not ((r.likes_count >= 0)) then errors.Add("Article likes count must not be negative")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listArticleHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> ArticleDb.search conn qv
            | _ -> ArticleDb.getAll conn
        let dtos = rows |> List.map articleToDto
        json dtos next ctx

let getArticleHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleDb.getById conn id with
        | Some row -> json (articleToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createArticleHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<ArticleCreateRequest>()
        match validateArticle dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = ArticleDb.create conn dto
        match ArticleDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (articleToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateArticleHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<ArticleCreateRequest>()
        match validateArticle dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        ArticleDb.update conn id dto |> ignore
        match ArticleDb.getById conn id with
        | Some row -> return! json (articleToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchArticleHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<ArticlePatchRequest>()
        ArticleDb.patch conn id patch |> ignore
        match ArticleDb.getById conn id with
        | Some row -> return! json (articleToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let transitionArticleHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Draft", "Published"); ("Published", "Archived"); ("Archived", "Draft"); ("Published", "Draft")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            ArticleDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorPublishHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement publish behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorArchiveHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement archive behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorReplaceHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement replace behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIncrementViewHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement increment_view behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorLikeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement like behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUnlikeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement unlike behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorReadingTimeMinutesHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement reading_time_minutes behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let articlesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/articles" >=> choose [
            GET  >=> listArticleHandler conn
            POST >=> createArticleHandler conn
        ]
        routef "/api/articles/%d" (fun id -> choose [
            GET    >=> getArticleHandler id conn
            PUT    >=> updateArticleHandler id conn
            PATCH  >=> patchArticleHandler id conn
        ])
        routef "/api/articles/%d/publish" (fun id -> behaviorPublishHandler id conn)
        routef "/api/articles/%d/archive" (fun id -> behaviorArchiveHandler id conn)
        routef "/api/articles/%d/view" (fun id -> behaviorIncrementViewHandler id conn)
        routef "/api/articles/%d/like" (fun id -> behaviorLikeHandler id conn)
        routef "/api/articles/%d/like" (fun id -> behaviorUnlikeHandler id conn)
        routef "/api/articles/%d/reading-time" (fun id -> behaviorReadingTimeMinutesHandler id conn)
        routef "/api/articles/%d/transitions/%s" (fun (id, toState) -> transitionArticleHandler id toState conn)
    ]