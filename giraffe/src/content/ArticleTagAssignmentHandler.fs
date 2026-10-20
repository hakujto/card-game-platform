module cards_project.content.ArticleTagAssignmentHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.ArticleTagAssignmentTypes

let listArticleTagAssignmentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = ArticleTagAssignmentDb.getAll conn
        let dtos = rows |> List.map article_tag_assignmentToDto
        json dtos next ctx

let getArticleTagAssignmentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleTagAssignmentDb.getById conn id with
        | Some row -> json (article_tag_assignmentToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createArticleTagAssignmentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<ArticleTagAssignmentCreateRequest>()
        let newId = ArticleTagAssignmentDb.create conn dto
        match ArticleTagAssignmentDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (article_tag_assignmentToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteArticleTagAssignmentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ArticleTagAssignmentDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        ArticleTagAssignmentDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let article_tag_assignmentsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/article_tag_assignments" >=> choose [
            GET  >=> listArticleTagAssignmentHandler conn
            POST >=> createArticleTagAssignmentHandler conn
        ]
        routef "/api/article_tag_assignments/%d" (fun id -> choose [
            GET    >=> getArticleTagAssignmentHandler id conn
            DELETE >=> deleteArticleTagAssignmentHandler id conn
        ])
    ]