module cards_project.cards.DeckSideboardCardHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.DeckSideboardCardTypes

let validateDeckSideboardCard (r: DeckSideboardCardCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.quantity >= 1 && r.quantity <= 4)) then errors.Add("Sideboard card quantity must be between 1 and 4 copies")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listDeckSideboardCardHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = DeckSideboardCardDb.getAll conn
        let dtos = rows |> List.map deck_sideboard_cardToDto
        json dtos next ctx

let getDeckSideboardCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckSideboardCardDb.getById conn id with
        | Some row -> json (deck_sideboard_cardToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDeckSideboardCardHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DeckSideboardCardCreateRequest>()
        match validateDeckSideboardCard dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = DeckSideboardCardDb.create conn dto
        match DeckSideboardCardDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (deck_sideboard_cardToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchDeckSideboardCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckSideboardCardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<DeckSideboardCardUpdateRequest>()
        DeckSideboardCardDb.patch conn id patch |> ignore
        match DeckSideboardCardDb.getById conn id with
        | Some row -> return! json (deck_sideboard_cardToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteDeckSideboardCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckSideboardCardDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        DeckSideboardCardDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorIncrementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckSideboardCardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement increment behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDecrementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckSideboardCardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement decrement behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let deck_sideboard_cardsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/deck_sideboard_cards" >=> choose [
            GET  >=> listDeckSideboardCardHandler conn
            POST >=> createDeckSideboardCardHandler conn
        ]
        routef "/api/deck_sideboard_cards/%d" (fun id -> choose [
            GET    >=> getDeckSideboardCardHandler id conn
            PATCH  >=> patchDeckSideboardCardHandler id conn
            DELETE >=> deleteDeckSideboardCardHandler id conn
        ])
        routef "/api/deck_sideboard_cards/%d/api/sideboard-cards/{id}/increment" (fun id -> behaviorIncrementHandler id conn)
        routef "/api/deck_sideboard_cards/%d/api/sideboard-cards/{id}/decrement" (fun id -> behaviorDecrementHandler id conn)
    ]