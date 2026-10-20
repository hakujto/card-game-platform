module cards_project.marketplace.TradeDisputeHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.TradeDisputeTypes

let validateTradeDispute (r: TradeDisputeCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.resolved_at <> None)) || (r.status = "Resolved"))) then errors.Add("resolved_at_requires_terminal_status")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTradeDisputeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TradeDisputeDb.getAll conn
        let dtos = rows |> List.map trade_disputeToDto
        json dtos next ctx

let getTradeDisputeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TradeDisputeDb.getById conn id with
        | Some row -> json (trade_disputeToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTradeDisputeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TradeDisputeCreateRequest>()
        match validateTradeDispute dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TradeDisputeDb.create conn dto
        match TradeDisputeDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (trade_disputeToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let transitionTradeDisputeHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeDisputeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Open", "UnderReview"); ("UnderReview", "Resolved"); ("UnderReview", "Escalated"); ("Escalated", "Resolved"); ("Resolved", "Open")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            TradeDisputeDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorEscalateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeDisputeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement escalate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorResolveHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeDisputeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement resolve behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCloseResolvedHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeDisputeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement close_resolved behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorReviewHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeDisputeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement review behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let trade_disputesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/trade_disputes" >=> choose [
            GET  >=> listTradeDisputeHandler conn
            POST >=> createTradeDisputeHandler conn
        ]
        routef "/api/trade_disputes/%d" (fun id -> choose [
            GET    >=> getTradeDisputeHandler id conn
        ])
        routef "/api/trade_disputes/%d/api/disputes/{id}/escalate" (fun id -> behaviorEscalateHandler id conn)
        routef "/api/trade_disputes/%d/api/disputes/{id}/resolve" (fun id -> behaviorResolveHandler id conn)
        routef "/api/trade_disputes/%d/api/disputes/{id}/close" (fun id -> behaviorCloseResolvedHandler id conn)
        routef "/api/trade_disputes/%d/api/disputes/{id}/review" (fun id -> behaviorReviewHandler id conn)
        routef "/api/trade_disputes/%d/transitions/%s" (fun (id, toState) -> transitionTradeDisputeHandler id toState conn)
    ]