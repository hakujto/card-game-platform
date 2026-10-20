module cards_project.cards.CardHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.CardTypes

let validateCard (r: CardCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.card_type = "Creature")) || ((r.attack <> None) && (r.defense <> None)))) then errors.Add("Creature card must have attack and defense")
    if not ((not ((r.card_type = "Planeswalker")) || (r.loyalty <> None))) then errors.Add("Planeswalker card must have loyalty")
    if not ((not ((r.card_type = "Land")) || (r.mana_cost = 0))) then errors.Add("Land card must have zero mana cost")
    if not ((not ((r.card_type = "Planeswalker")) || (r.loyalty = None))) then errors.Add("Only Planeswalker cards can have loyalty")
    if not ((r.mana_cost >= 0 && r.mana_cost <= 20)) then errors.Add("mana_cost must be between 0 and 20")
    if not ((r.power_level >= 1 && r.power_level <= 10)) then errors.Add("power_level must be between 1 and 10")
    if not ((not (((r.is_banned = true) && (r.is_restricted = true))))) then errors.Add("Card cannot be both banned and restricted at the same time")
    if not ((not ((r.is_banned = true)) || (r.legal_formats = "[]"))) then errors.Add("Banned card must not appear in any legal formats")
    if r.mana_cost < 0 then errors.Add("mana_cost must be >= 0")
    if r.mana_cost > 20 then errors.Add("mana_cost must be <= 20")
    if r.card_type = "Creature" && r.attack.IsNone then errors.Add("attack is required when card_type = Creature")
    if r.card_type = "Creature" && r.defense.IsNone then errors.Add("defense is required when card_type = Creature")
    if r.card_type = "Planeswalker" && r.loyalty.IsNone then errors.Add("loyalty is required when card_type = Planeswalker")
    if r.power_level < 1 then errors.Add("power_level must be >= 1")
    if r.power_level > 10 then errors.Add("power_level must be <= 10")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listCardHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> CardDb.search conn qv
            | _ -> CardDb.getAll conn
        let dtos = rows |> List.map cardToDto
        json dtos next ctx

let getCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardDb.getById conn id with
        | Some row -> json (cardToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCardHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CardCreateRequest>()
        match validateCard dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = CardDb.create conn dto
        match CardDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (cardToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<CardCreateRequest>()
        match validateCard dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        CardDb.update conn id dto |> ignore
        match CardDb.getById conn id with
        | Some row -> return! json (cardToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<CardPatchRequest>()
        CardDb.patch conn id patch |> ignore
        match CardDb.getById conn id with
        | Some row -> return! json (cardToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorBanHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement ban behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUnbanHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement unban behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRestrictHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement restrict behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUnrestrictHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement unrestrict behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorReplaceHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement replace behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCalculateValueHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement calculate_value behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorApplyRarityBonusHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement apply_rarity_bonus behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsLegalInFormatHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_legal_in_format behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let cardsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/cards" >=> choose [
            GET  >=> listCardHandler conn
            POST >=> createCardHandler conn
        ]
        routef "/api/cards/%d" (fun id -> choose [
            GET    >=> getCardHandler id conn
            PUT    >=> updateCardHandler id conn
            PATCH  >=> patchCardHandler id conn
        ])
        routef "/api/cards/%d/ban" (fun id -> behaviorBanHandler id conn)
        routef "/api/cards/%d/unban" (fun id -> behaviorUnbanHandler id conn)
        routef "/api/cards/%d/restrict" (fun id -> behaviorRestrictHandler id conn)
        routef "/api/cards/%d/unrestrict" (fun id -> behaviorUnrestrictHandler id conn)
        routef "/api/cards/%d/value" (fun id -> behaviorCalculateValueHandler id conn)
        routef "/api/cards/%d/rarity-bonus" (fun id -> behaviorApplyRarityBonusHandler id conn)
        routef "/api/cards/%d/legal" (fun id -> behaviorIsLegalInFormatHandler id conn)
    ]