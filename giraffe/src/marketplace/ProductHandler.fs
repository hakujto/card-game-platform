module cards_project.marketplace.ProductHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.ProductTypes

let validateProduct (r: ProductCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.price > 0)) then errors.Add("Product price must be greater than zero")
    if not ((r.stock >= 0)) then errors.Add("Product stock must not be negative")
    if not ((r.discount_percent >= 0 && r.discount_percent <= 100)) then errors.Add("Product discount percent must be between 0 and 100")
    if r.discount_percent < 0 then errors.Add("discount_percent must be >= 0")
    if r.discount_percent > 100 then errors.Add("discount_percent must be <= 100")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listProductHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> ProductDb.search conn qv
            | _ -> ProductDb.getAll conn
        let dtos = rows |> List.map productToDto
        json dtos next ctx

let getProductHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match ProductDb.getById conn id with
        | Some row -> json (productToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createProductHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<ProductCreateRequest>()
        match validateProduct dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = ProductDb.create conn dto
        match ProductDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (productToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateProductHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<ProductCreateRequest>()
        match validateProduct dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        ProductDb.update conn id dto |> ignore
        match ProductDb.getById conn id with
        | Some row -> return! json (productToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchProductHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<ProductPatchRequest>()
        ProductDb.patch conn id patch |> ignore
        match ProductDb.getById conn id with
        | Some row -> return! json (productToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorActivateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement activate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDeactivateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement deactivate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorApplyDiscountHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement apply_discount behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRestockHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement restock behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorEffectivePriceHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement effective_price behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsInStockHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match ProductDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_in_stock behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let productsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/products" >=> choose [
            GET  >=> listProductHandler conn
            POST >=> createProductHandler conn
        ]
        routef "/api/products/%d" (fun id -> choose [
            GET    >=> getProductHandler id conn
            PUT    >=> updateProductHandler id conn
            PATCH  >=> patchProductHandler id conn
        ])
        routef "/api/products/%d/activate" (fun id -> behaviorActivateHandler id conn)
        routef "/api/products/%d/deactivate" (fun id -> behaviorDeactivateHandler id conn)
        routef "/api/products/%d/discount" (fun id -> behaviorApplyDiscountHandler id conn)
        routef "/api/products/%d/restock" (fun id -> behaviorRestockHandler id conn)
        routef "/api/products/%d/effective-price" (fun id -> behaviorEffectivePriceHandler id conn)
        routef "/api/products/%d/in-stock" (fun id -> behaviorIsInStockHandler id conn)
    ]