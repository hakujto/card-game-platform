module cards_project.content.ArticleTagHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.ArticleTagTypes

let listArticleTagHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> ArticleTagDb.search conn qv
            | _ -> ArticleTagDb.getAll conn
        let dtos = rows |> List.map article_tagToDto
        json dtos next ctx

let getArticleTagHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleTagDb.getById conn id with
        | Some row -> json (article_tagToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createArticleTagHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<ArticleTagCreateRequest>()
        let newId = ArticleTagDb.create conn dto
        match ArticleTagDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (article_tagToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchArticleTagHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleTagDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<ArticleTagUpdateRequest>()
        ArticleTagDb.patch conn id patch |> ignore
        match ArticleTagDb.getById conn id with
        | Some row -> return! json (article_tagToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteArticleTagHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleTagDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        ArticleTagDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorRenameHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleTagDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement rename behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorArticleCountHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleTagDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement article_count behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let article_tagsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/article_tags" >=> choose [
            GET  >=> listArticleTagHandler conn
            POST >=> createArticleTagHandler conn
        ]
        routef "/api/article_tags/%d" (fun id -> choose [
            GET    >=> getArticleTagHandler id conn
            PATCH  >=> patchArticleTagHandler id conn
            DELETE >=> deleteArticleTagHandler id conn
        ])
        routef "/api/article_tags/%d/rename" (fun id -> behaviorRenameHandler id conn)
        routef "/api/article_tags/%d/article-count" (fun id -> behaviorArticleCountHandler id conn)
    ]