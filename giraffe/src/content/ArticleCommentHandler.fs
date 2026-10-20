module cards_project.content.ArticleCommentHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.ArticleCommentTypes

let listArticleCommentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = ArticleCommentDb.getAll conn
        let dtos = rows |> List.map article_commentToDto
        json dtos next ctx

let getArticleCommentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleCommentDb.getById conn id with
        | Some row -> json (article_commentToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createArticleCommentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<ArticleCommentCreateRequest>()
        let newId = ArticleCommentDb.create conn dto
        match ArticleCommentDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (article_commentToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteArticleCommentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleCommentDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        ArticleCommentDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorHideHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleCommentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement hide behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUnhideHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleCommentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement unhide behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsReplyHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ArticleCommentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_reply behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let article_commentsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/article_comments" >=> choose [
            GET  >=> listArticleCommentHandler conn
            POST >=> createArticleCommentHandler conn
        ]
        routef "/api/article_comments/%d" (fun id -> choose [
            GET    >=> getArticleCommentHandler id conn
            DELETE >=> deleteArticleCommentHandler id conn
        ])
        routef "/api/article_comments/%d/api/comments/{id}/hide" (fun id -> behaviorHideHandler id conn)
        routef "/api/article_comments/%d/api/comments/{id}/unhide" (fun id -> behaviorUnhideHandler id conn)
        routef "/api/article_comments/%d/api/comments/{id}/is-reply" (fun id -> behaviorIsReplyHandler id conn)
    ]