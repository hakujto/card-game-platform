module cards_project.marketplace.CardPriceHistoryHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.CardPriceHistoryTypes

let validateCardPriceHistory (r: CardPriceHistoryCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not (((r.min_price <= r.avg_price) && (r.avg_price <= r.max_price))) then errors.Add("min_price <= avg_price <= max_price must hold")
    if not ((r.volume >= 0)) then errors.Add("Price history volume must not be negative")
    if not ((r.min_price >= 0)) then errors.Add("Prices must not be negative")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listCardPriceHistoryHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = CardPriceHistoryDb.getAll conn
        let dtos = rows |> List.map card_price_historyToDto
        json dtos next ctx

let getCardPriceHistoryHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CardPriceHistoryDb.getById conn id with
        | Some row -> json (card_price_historyToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let behaviorPriceChangePercentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardPriceHistoryDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement price_change_percent behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsPriceSpikeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CardPriceHistoryDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_price_spike behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let card_price_historiesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/card_price_histories" >=> choose [
            GET  >=> listCardPriceHistoryHandler conn
        ]
        routef "/api/card_price_histories/%d" (fun id -> choose [
            GET    >=> getCardPriceHistoryHandler id conn
        ])
        routef "/api/card_price_histories/%d/api/price-history/{id}/change" (fun id -> behaviorPriceChangePercentHandler id conn)
        routef "/api/card_price_histories/%d/api/price-history/{id}/spike" (fun id -> behaviorIsPriceSpikeHandler id conn)
    ]