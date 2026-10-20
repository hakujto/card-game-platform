module cards_project.marketplace.OrderItemHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.OrderItemTypes

let validateOrderItem (r: OrderItemCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.quantity > 0)) then errors.Add("Order item quantity must be greater than zero")
    if not ((r.price_at_purchase >= 0)) then errors.Add("Price at purchase must not be negative")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listOrderItemHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = OrderItemDb.getAll conn
        let dtos = rows |> List.map order_itemToDto
        json dtos next ctx

let getOrderItemHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match OrderItemDb.getById conn id with
        | Some row -> json (order_itemToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createOrderItemHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<OrderItemCreateRequest>()
        match validateOrderItem dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = OrderItemDb.create conn dto
        match OrderItemDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (order_itemToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteOrderItemHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match OrderItemDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        OrderItemDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorLineTotalHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match OrderItemDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement line_total behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let order_itemsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/order_items" >=> choose [
            GET  >=> listOrderItemHandler conn
            POST >=> createOrderItemHandler conn
        ]
        routef "/api/order_items/%d" (fun id -> choose [
            GET    >=> getOrderItemHandler id conn
            DELETE >=> deleteOrderItemHandler id conn
        ])
        routef "/api/order_items/%d/total" (fun id -> behaviorLineTotalHandler id conn)
    ]