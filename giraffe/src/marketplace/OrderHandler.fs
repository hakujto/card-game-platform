module cards_project.marketplace.OrderHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.OrderTypes

let validateOrder (r: OrderCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.status = "Paid")) || (r.paid_at <> None))) then errors.Add("Paid order must have paid_at set")
    if not ((not ((r.status = "Shipped")) || (r.tracking_number <> None))) then errors.Add("Shipped order must have a tracking number")
    if not ((not ((r.shipped_at <> None)) || (r.status = "Shipped"))) then errors.Add("shipped_at_requires_shipped_status")
    if not ((r.total >= 0)) then errors.Add("Order total must not be negative")
    if not ((r.discount_applied <= r.total)) then errors.Add("Discount applied cannot exceed order total")
    if not (System.Text.RegularExpressions.Regex.IsMatch(r.currency, @"[A-Z]{3}")) then errors.Add("currency must match pattern [A-Z]{3}")
    if r.status = "Shipped" && r.tracking_number.IsNone then errors.Add("tracking_number is required when status = Shipped")
    if r.status = "Paid" && r.paid_at.IsNone then errors.Add("paid_at is required when status = Paid")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listOrderHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = OrderDb.getAll conn
        let dtos = rows |> List.map orderToDto
        json dtos next ctx

let getOrderHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match OrderDb.getById conn id with
        | Some row -> json (orderToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createOrderHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<OrderCreateRequest>()
        match validateOrder dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = OrderDb.create conn dto
        match OrderDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (orderToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let transitionOrderHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Pending", "Paid"); ("Paid", "Processing"); ("Processing", "Shipped"); ("Shipped", "Completed"); ("Pending", "Cancelled"); ("Paid", "Cancelled"); ("Completed", "Refunded"); ("Refunded", "Completed"); ("Completed", "Cancelled")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            OrderDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorCancelHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement cancel behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorPayHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        // @guard: status = Pending
        let role = ctx.GetCookieValue "role" |> Option.defaultValue ""
        if role <> "Pending" then
            return! (setStatusCode 403 >=> json {| error = "Guard failed: status = Pending" |}) next ctx
        else
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement pay behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorProcessPaymentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement process_payment behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCalculateTotalHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement calculate_total behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorApplyDiscountHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement apply_discount behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRefundHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement refund behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let ordersRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/orders" >=> choose [
            GET  >=> listOrderHandler conn
            POST >=> createOrderHandler conn
        ]
        routef "/api/orders/%d" (fun id -> choose [
            GET    >=> getOrderHandler id conn
        ])
        routef "/api/orders/%d/cancel" (fun id -> behaviorCancelHandler id conn)
        routef "/api/orders/%d/pay" (fun id -> behaviorPayHandler id conn)
        routef "/api/orders/%d/process-payment" (fun id -> behaviorProcessPaymentHandler id conn)
        routef "/api/orders/%d/total" (fun id -> behaviorCalculateTotalHandler id conn)
        routef "/api/orders/%d/discount" (fun id -> behaviorApplyDiscountHandler id conn)
        routef "/api/orders/%d/refund" (fun id -> behaviorRefundHandler id conn)
        routef "/api/orders/%d/transitions/%s" (fun (id, toState) -> transitionOrderHandler id toState conn)
    ]