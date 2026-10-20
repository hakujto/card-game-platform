module cards_project.marketplace.CouponHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.marketplace.CouponTypes

let validateCoupon (r: CouponCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.valid_until > r.valid_from)) then errors.Add("Coupon expiry must be after its start date")
    if not ((r.discount_value > 0)) then errors.Add("Discount value must be greater than zero")
    if not ((not ((r.discount_type = "Percent")) || (r.discount_value >= 1m && r.discount_value <= 100m))) then errors.Add("Percent discount must be between 1 and 100")
    if not ((not ((r.max_uses <> None)) || (r.max_uses |> Option.map (fun b -> r.uses_count <= b) |> Option.defaultValue false))) then errors.Add("Coupon uses count cannot exceed max_uses")
    if r.discount_value < 0.01m then errors.Add("discount_value must be >= 0.01")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listCouponHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> CouponDb.search conn qv
            | _ -> CouponDb.getAll conn
        let dtos = rows |> List.map couponToDto
        json dtos next ctx

let getCouponHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CouponDb.getById conn id with
        | Some row -> json (couponToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCouponHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CouponCreateRequest>()
        match validateCoupon dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = CouponDb.create conn dto
        match CouponDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (couponToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateCouponHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CouponDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<CouponCreateRequest>()
        match validateCoupon dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        CouponDb.update conn id dto |> ignore
        match CouponDb.getById conn id with
        | Some row -> return! json (couponToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchCouponHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CouponDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<CouponUpdateRequest>()
        CouponDb.patch conn id patch |> ignore
        match CouponDb.getById conn id with
        | Some row -> return! json (couponToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorIsValidHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CouponDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_valid behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsApplicableToOrderHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CouponDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_applicable_to_order behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRedeemHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        // @guard: is_active = true
        let role = ctx.GetCookieValue "role" |> Option.defaultValue ""
        if role <> "true" then
            return! (setStatusCode 403 >=> json {| error = "Guard failed: is_active = true" |}) next ctx
        else
        match CouponDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement redeem behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDeactivateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CouponDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement deactivate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let couponsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/coupons" >=> choose [
            GET  >=> listCouponHandler conn
            POST >=> createCouponHandler conn
        ]
        routef "/api/coupons/%d" (fun id -> choose [
            GET    >=> getCouponHandler id conn
            PUT    >=> updateCouponHandler id conn
            PATCH  >=> patchCouponHandler id conn
        ])
        routef "/api/coupons/%d/valid" (fun id -> behaviorIsValidHandler id conn)
        routef "/api/coupons/%d/applicable" (fun id -> behaviorIsApplicableToOrderHandler id conn)
        routef "/api/coupons/%d/redeem" (fun id -> behaviorRedeemHandler id conn)
        routef "/api/coupons/%d/deactivate" (fun id -> behaviorDeactivateHandler id conn)
    ]