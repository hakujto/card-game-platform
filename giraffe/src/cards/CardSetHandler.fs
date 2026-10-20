module cards_project.cards.CardSetHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.CardSetTypes

let validateCardSet (r: CardSetCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.total_cards > 0)) then errors.Add("Card set must have at least one card")
    if not ((not ((r.rotation_date <> None)) || (r.rotation_date > Some r.release_date))) then errors.Add("Rotation date must be after release date")
    if not ((not ((r.is_rotated = true)) || (r.rotation_date <> None))) then errors.Add("Rotated set must have a rotation date")
    if not (System.Text.RegularExpressions.Regex.IsMatch(r.code, @"[A-Z]{2,6}")) then errors.Add("code must match pattern [A-Z]{2,6}")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listCardSetHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> CardSetDb.search conn qv
            | _ -> CardSetDb.getAll conn
        let dtos = rows |> List.map card_setToDto
        json dtos next ctx

let getCardSetHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardSetDb.getById conn id with
        | Some row -> json (card_setToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCardSetHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CardSetCreateRequest>()
        match validateCardSet dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = CardSetDb.create conn dto
        match CardSetDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (card_setToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateCardSetHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardSetDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<CardSetCreateRequest>()
        match validateCardSet dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        CardSetDb.update conn id dto |> ignore
        match CardSetDb.getById conn id with
        | Some row -> return! json (card_setToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchCardSetHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardSetDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<CardSetUpdateRequest>()
        CardSetDb.patch conn id patch |> ignore
        match CardSetDb.getById conn id with
        | Some row -> return! json (card_setToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorIsLegalInStandardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardSetDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_legal_in_standard behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsLegalInFormatHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardSetDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_legal_in_format behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCardCountByRarityHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardSetDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement card_count_by_rarity behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRotateOutHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardSetDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement rotate_out behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let card_setsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/card_sets" >=> choose [
            GET  >=> listCardSetHandler conn
            POST >=> createCardSetHandler conn
        ]
        routef "/api/card_sets/%d" (fun id -> choose [
            GET    >=> getCardSetHandler id conn
            PUT    >=> updateCardSetHandler id conn
            PATCH  >=> patchCardSetHandler id conn
        ])
        routef "/api/card_sets/%d/standard-legal" (fun id -> behaviorIsLegalInStandardHandler id conn)
        routef "/api/card_sets/%d/legal" (fun id -> behaviorIsLegalInFormatHandler id conn)
        routef "/api/card_sets/%d/rarity-count" (fun id -> behaviorCardCountByRarityHandler id conn)
        routef "/api/card_sets/%d/rotate" (fun id -> behaviorRotateOutHandler id conn)
    ]