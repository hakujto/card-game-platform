module cards_project.cards.DeckCardHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.DeckCardTypes

let validateDeckCard (r: DeckCardCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.quantity >= 1 && r.quantity <= 4)) then errors.Add("A deck can contain between 1 and 4 copies of a card")
    if not ((not ((r.is_commander = true)) || (r.quantity = 1))) then errors.Add("Commander card must appear exactly once in the deck")
    if r.quantity < 1 then errors.Add("quantity must be >= 1")
    if r.quantity > 4 then errors.Add("quantity must be <= 4")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listDeckCardHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = DeckCardDb.getAll conn
        let dtos = rows |> List.map deck_cardToDto
        json dtos next ctx

let getDeckCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckCardDb.getById conn id with
        | Some row -> json (deck_cardToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDeckCardHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DeckCardCreateRequest>()
        match validateDeckCard dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = DeckCardDb.create conn dto
        match DeckCardDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (deck_cardToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchDeckCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckCardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<DeckCardUpdateRequest>()
        DeckCardDb.patch conn id patch |> ignore
        match DeckCardDb.getById conn id with
        | Some row -> return! json (deck_cardToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteDeckCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckCardDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        DeckCardDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorIncrementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckCardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement increment behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDecrementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckCardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement decrement behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let deck_cardsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/deck_cards" >=> choose [
            GET  >=> listDeckCardHandler conn
            POST >=> createDeckCardHandler conn
        ]
        routef "/api/deck_cards/%d" (fun id -> choose [
            GET    >=> getDeckCardHandler id conn
            PATCH  >=> patchDeckCardHandler id conn
            DELETE >=> deleteDeckCardHandler id conn
        ])
        routef "/api/deck_cards/%d/increment" (fun id -> behaviorIncrementHandler id conn)
        routef "/api/deck_cards/%d/decrement" (fun id -> behaviorDecrementHandler id conn)
    ]