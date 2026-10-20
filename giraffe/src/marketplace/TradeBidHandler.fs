module cards_project.marketplace.TradeBidHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.TradeBidTypes

let validateTradeBid (r: TradeBidCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.amount > 0)) then errors.Add("Bid amount must be greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTradeBidHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TradeBidDb.getAll conn
        let dtos = rows |> List.map trade_bidToDto
        json dtos next ctx

let getTradeBidHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TradeBidDb.getById conn id with
        | Some row -> json (trade_bidToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTradeBidHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TradeBidCreateRequest>()
        match validateTradeBid dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TradeBidDb.create conn dto
        match TradeBidDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (trade_bidToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let behaviorOutbidByHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeBidDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement outbid_by behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRetractHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeBidDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement retract behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let trade_bidsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/trade_bids" >=> choose [
            GET  >=> listTradeBidHandler conn
            POST >=> createTradeBidHandler conn
        ]
        routef "/api/trade_bids/%d" (fun id -> choose [
            GET    >=> getTradeBidHandler id conn
        ])
        routef "/api/trade_bids/%d/api/bids/{id}/outbid" (fun id -> behaviorOutbidByHandler id conn)
        routef "/api/trade_bids/%d/api/bids/{id}" (fun id -> behaviorRetractHandler id conn)
    ]