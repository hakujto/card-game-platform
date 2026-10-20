module cards_project.marketplace.TradeListingHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.TradeListingTypes

let validateTradeListing (r: TradeListingCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.listing_type = "FixedPrice")) || (r.asking_price <> None))) then errors.Add("Fixed price listing must have an asking price")
    if not ((not ((r.listing_type = "Auction")) || ((r.auction_start_price <> None) && (r.auction_end_time <> None)))) then errors.Add("Auction listing must have a start price and end time")
    if not ((r.quantity >= 1 && r.quantity <= 9999)) then errors.Add("Listing quantity must be between 1 and 9999")
    if r.listing_type = "FixedPrice" && r.asking_price.IsNone then errors.Add("asking_price is required when listing_type = FixedPrice")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTradeListingHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> TradeListingDb.search conn qv
            | _ -> TradeListingDb.getAll conn
        let dtos = rows |> List.map trade_listingToDto
        json dtos next ctx

let getTradeListingHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TradeListingDb.getById conn id with
        | Some row -> json (trade_listingToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTradeListingHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TradeListingCreateRequest>()
        match validateTradeListing dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TradeListingDb.create conn dto
        match TradeListingDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (trade_listingToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchTradeListingHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<TradeListingUpdateRequest>()
        TradeListingDb.patch conn id patch |> ignore
        match TradeListingDb.getById conn id with
        | Some row -> return! json (trade_listingToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let transitionTradeListingHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Pending", "Active"); ("Active", "Sold"); ("Active", "Expired"); ("Active", "Cancelled"); ("Sold", "Active"); ("Expired", "Active")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            TradeListingDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorCloseHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement close behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorExtendHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement extend behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCancelHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        // @guard: status = Active
        let role = ctx.GetCookieValue "role" |> Option.defaultValue ""
        if role <> "Active" then
            return! (setStatusCode 403 >=> json {| error = "Guard failed: status = Active" |}) next ctx
        else
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement cancel behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsExpiredHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_expired behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorFinalizeAuctionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TradeListingDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement finalize_auction behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let trade_listingsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/trade_listings" >=> choose [
            GET  >=> listTradeListingHandler conn
            POST >=> createTradeListingHandler conn
        ]
        routef "/api/trade_listings/%d" (fun id -> choose [
            GET    >=> getTradeListingHandler id conn
            PATCH  >=> patchTradeListingHandler id conn
        ])
        routef "/api/trade_listings/%d/close" (fun id -> behaviorCloseHandler id conn)
        routef "/api/trade_listings/%d/extend" (fun id -> behaviorExtendHandler id conn)
        routef "/api/trade_listings/%d/cancel" (fun id -> behaviorCancelHandler id conn)
        routef "/api/trade_listings/%d/expired" (fun id -> behaviorIsExpiredHandler id conn)
        routef "/api/trade_listings/%d/finalize" (fun id -> behaviorFinalizeAuctionHandler id conn)
        routef "/api/trade_listings/%d/transitions/%s" (fun (id, toState) -> transitionTradeListingHandler id toState conn)
    ]