module cards_project.cards.DeckTagAssignmentHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.DeckTagAssignmentTypes

let listDeckTagAssignmentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = DeckTagAssignmentDb.getAll conn
        let dtos = rows |> List.map deck_tag_assignmentToDto
        json dtos next ctx

let getDeckTagAssignmentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckTagAssignmentDb.getById conn id with
        | Some row -> json (deck_tag_assignmentToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDeckTagAssignmentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DeckTagAssignmentCreateRequest>()
        let newId = DeckTagAssignmentDb.create conn dto
        match DeckTagAssignmentDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (deck_tag_assignmentToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteDeckTagAssignmentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckTagAssignmentDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        DeckTagAssignmentDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let deck_tag_assignmentsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/deck_tag_assignments" >=> choose [
            GET  >=> listDeckTagAssignmentHandler conn
            POST >=> createDeckTagAssignmentHandler conn
        ]
        routef "/api/deck_tag_assignments/%d" (fun id -> choose [
            GET    >=> getDeckTagAssignmentHandler id conn
            DELETE >=> deleteDeckTagAssignmentHandler id conn
        ])
    ]