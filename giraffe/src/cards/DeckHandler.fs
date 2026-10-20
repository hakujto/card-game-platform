module cards_project.cards.DeckHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.DeckTypes

let validateDeck (r: DeckCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.wins >= 0)) then errors.Add("Deck wins count must not be negative")
    if not ((r.losses >= 0)) then errors.Add("Deck losses count must not be negative")
    if not ((r.draws >= 0)) then errors.Add("Deck draws count must not be negative")
    if not ((not ((r.is_tournament_legal = true)) || (r.is_public = true))) then errors.Add("Tournament-legal deck must be made public")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listDeckHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> DeckDb.search conn qv
            | _ -> DeckDb.getAll conn
        let dtos = rows |> List.map deckToDto
        json dtos next ctx

let getDeckHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckDb.getById conn id with
        | Some row -> json (deckToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDeckHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DeckCreateRequest>()
        match validateDeck dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = DeckDb.create conn dto
        match DeckDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (deckToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateDeckHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<DeckCreateRequest>()
        match validateDeck dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        DeckDb.update conn id dto |> ignore
        match DeckDb.getById conn id with
        | Some row -> return! json (deckToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchDeckHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<DeckPatchRequest>()
        DeckDb.patch conn id patch |> ignore
        match DeckDb.getById conn id with
        | Some row -> return! json (deckToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteDeckHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        DeckDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorValidateSizeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement validate_size behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorAddCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement add_card behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRemoveCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement remove_card behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorWinRateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement win_rate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCloneHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement clone behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorPublishHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement publish behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUnpublishHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement unpublish behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCertifyTournamentLegalHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement certify_tournament_legal behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let decksRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/decks" >=> choose [
            GET  >=> listDeckHandler conn
            POST >=> createDeckHandler conn
        ]
        routef "/api/decks/%d" (fun id -> choose [
            GET    >=> getDeckHandler id conn
            PUT    >=> updateDeckHandler id conn
            PATCH  >=> patchDeckHandler id conn
            DELETE >=> deleteDeckHandler id conn
        ])
        routef "/api/decks/%d/validate" (fun id -> behaviorValidateSizeHandler id conn)
        routef "/api/decks/%d/cards" (fun id -> behaviorAddCardHandler id conn)
        routef "/api/decks/%d/cards/{card_id}" (fun id -> behaviorRemoveCardHandler id conn)
        routef "/api/decks/%d/win-rate" (fun id -> behaviorWinRateHandler id conn)
        routef "/api/decks/%d/clone" (fun id -> behaviorCloneHandler id conn)
        routef "/api/decks/%d/publish" (fun id -> behaviorPublishHandler id conn)
        routef "/api/decks/%d/unpublish" (fun id -> behaviorUnpublishHandler id conn)
        routef "/api/decks/%d/certify" (fun id -> behaviorCertifyTournamentLegalHandler id conn)
    ]