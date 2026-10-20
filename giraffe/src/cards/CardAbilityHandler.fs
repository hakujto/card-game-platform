module cards_project.cards.CardAbilityHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.CardAbilityTypes

let validateCardAbility (r: CardAbilityCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.ability_type = "Keyword")) || (r.keyword <> None))) then errors.Add("Keyword ability must have a keyword name")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listCardAbilityHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> CardAbilityDb.search conn qv
            | _ -> CardAbilityDb.getAll conn
        let dtos = rows |> List.map card_abilityToDto
        json dtos next ctx

let getCardAbilityHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardAbilityDb.getById conn id with
        | Some row -> json (card_abilityToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCardAbilityHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CardAbilityCreateRequest>()
        match validateCardAbility dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = CardAbilityDb.create conn dto
        match CardAbilityDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (card_abilityToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateCardAbilityHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardAbilityDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<CardAbilityCreateRequest>()
        match validateCardAbility dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        CardAbilityDb.update conn id dto |> ignore
        match CardAbilityDb.getById conn id with
        | Some row -> return! json (card_abilityToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchCardAbilityHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardAbilityDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<CardAbilityUpdateRequest>()
        CardAbilityDb.patch conn id patch |> ignore
        match CardAbilityDb.getById conn id with
        | Some row -> return! json (card_abilityToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteCardAbilityHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardAbilityDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        CardAbilityDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorIsUsableAtHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardAbilityDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_usable_at behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDescribeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardAbilityDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement describe behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let card_abilitiesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/card_abilities" >=> choose [
            GET  >=> listCardAbilityHandler conn
            POST >=> createCardAbilityHandler conn
        ]
        routef "/api/card_abilities/%d" (fun id -> choose [
            GET    >=> getCardAbilityHandler id conn
            PUT    >=> updateCardAbilityHandler id conn
            PATCH  >=> patchCardAbilityHandler id conn
            DELETE >=> deleteCardAbilityHandler id conn
        ])
        routef "/api/card_abilities/%d/usable" (fun id -> behaviorIsUsableAtHandler id conn)
        routef "/api/card_abilities/%d/describe" (fun id -> behaviorDescribeHandler id conn)
    ]