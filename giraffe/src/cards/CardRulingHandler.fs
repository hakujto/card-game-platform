module cards_project.cards.CardRulingHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.CardRulingTypes

let listCardRulingHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = CardRulingDb.getAll conn
        let dtos = rows |> List.map card_rulingToDto
        json dtos next ctx

let getCardRulingHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardRulingDb.getById conn id with
        | Some row -> json (card_rulingToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCardRulingHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CardRulingCreateRequest>()
        let newId = CardRulingDb.create conn dto
        match CardRulingDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (card_rulingToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteCardRulingHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardRulingDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        CardRulingDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorIsCurrentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardRulingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_current behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorSupersedesPreviousHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardRulingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement supersedes_previous behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let card_rulingsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/card_rulings" >=> choose [
            GET  >=> listCardRulingHandler conn
            POST >=> createCardRulingHandler conn
        ]
        routef "/api/card_rulings/%d" (fun id -> choose [
            GET    >=> getCardRulingHandler id conn
            DELETE >=> deleteCardRulingHandler id conn
        ])
        routef "/api/card_rulings/%d/current" (fun id -> behaviorIsCurrentHandler id conn)
        routef "/api/card_rulings/%d/supersedes" (fun id -> behaviorSupersedesPreviousHandler id conn)
    ]