module cards_project.marketplace.TradeTransactionHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.TradeTransactionTypes

let validateTradeTransaction (r: TradeTransactionCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.platform_fee <= r.final_price)) then errors.Add("Platform fee cannot exceed the final price")
    if not ((r.platform_fee >= 0)) then errors.Add("Platform fee must not be negative")
    if not ((r.final_price > 0)) then errors.Add("Transaction final price must be greater than zero")
    if not ((not ((r.status = "Completed")) || (r.completed_at <> None))) then errors.Add("Completed transaction must have a completed_at timestamp")
    if r.status = "Completed" && r.completed_at.IsNone then errors.Add("completed_at is required when status = Completed")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTradeTransactionHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TradeTransactionDb.getAll conn
        let dtos = rows |> List.map trade_transactionToDto
        json dtos next ctx

let getTradeTransactionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TradeTransactionDb.getById conn id with
        | Some row -> json (trade_transactionToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let behaviorCompleteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeTransactionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement complete behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRefundHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeTransactionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement refund behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorOpenDisputeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeTransactionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement open_dispute behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorSellerNetHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeTransactionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement seller_net behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let trade_transactionsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/trade_transactions" >=> choose [
            GET  >=> listTradeTransactionHandler conn
        ]
        routef "/api/trade_transactions/%d" (fun id -> choose [
            GET    >=> getTradeTransactionHandler id conn
        ])
        routef "/api/trade_transactions/%d/api/transactions/{id}/complete" (fun id -> behaviorCompleteHandler id conn)
        routef "/api/trade_transactions/%d/api/transactions/{id}/refund" (fun id -> behaviorRefundHandler id conn)
        routef "/api/trade_transactions/%d/api/transactions/{id}/dispute" (fun id -> behaviorOpenDisputeHandler id conn)
        routef "/api/trade_transactions/%d/api/transactions/{id}/seller-net" (fun id -> behaviorSellerNetHandler id conn)
    ]