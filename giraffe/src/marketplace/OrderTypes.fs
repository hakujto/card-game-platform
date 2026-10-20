module cards_project.marketplace.OrderTypes

open System.Data

type OrderStatus =
    | Pending
    | Paid
    | Processing
    | Shipped
    | Completed
    | Cancelled
    | Refunded

    static member ToString = function
        | Pending -> "Pending"
        | Paid -> "Paid"
        | Processing -> "Processing"
        | Shipped -> "Shipped"
        | Completed -> "Completed"
        | Cancelled -> "Cancelled"
        | Refunded -> "Refunded"

    static member FromString s =
        match s with
        | "Pending" -> Pending
        | "Paid" -> Paid
        | "Processing" -> Processing
        | "Shipped" -> Shipped
        | "Completed" -> Completed
        | "Cancelled" -> Cancelled
        | "Refunded" -> Refunded
        | _ -> failwithf "Unknown OrderStatus: %s" s

type OrderPaymentMethod =
    | Card
    | PayPal
    | Crypto
    | PlatformCredits

    static member ToString = function
        | Card -> "Card"
        | PayPal -> "PayPal"
        | Crypto -> "Crypto"
        | PlatformCredits -> "PlatformCredits"

    static member FromString s =
        match s with
        | "Card" -> Card
        | "PayPal" -> PayPal
        | "Crypto" -> Crypto
        | "PlatformCredits" -> PlatformCredits
        | _ -> failwithf "Unknown OrderPaymentMethod: %s" s

[<CLIMutable>]
type OrderRow = {
    Id: int64
    Status: string
    Total: decimal
    DiscountApplied: decimal
    Currency: string
    PaymentMethod: string option
    PaymentReference: string option
    ShippingAddress: string option
    TrackingNumber: string option
    PaidAt: string option
    ShippedAt: string option
    PlayerId: int64
    CouponId: int64 option
    CreatedAt: string
    UpdatedAt: string
}

type OrderDto = {
    id: int64
    status: string
    total: decimal
    discount_applied: decimal
    currency: string
    payment_method: string option
    shipping_address: string option
    tracking_number: string option
    paidAt: string option
    shippedAt: string option
    player_id: int64
    coupon_id: int64 option
    created_at: string
    updated_at: string
}

let orderToDto (r: OrderRow) : OrderDto = {
    id = r.Id
    status = r.Status
    total = r.Total
    discount_applied = r.DiscountApplied
    currency = r.Currency
    payment_method = r.PaymentMethod
    shipping_address = r.ShippingAddress
    tracking_number = r.TrackingNumber
    paidAt = r.PaidAt
    shippedAt = r.ShippedAt
    player_id = r.PlayerId
    coupon_id = r.CouponId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type OrderCreateRequest = {
    status: string
    total: decimal
    discount_applied: decimal
    currency: string
    payment_method: string option
    payment_reference: string option
    shipping_address: string option
    tracking_number: string option
    paid_at: string option
    shipped_at: string option
    player_id: int64
    coupon_id: int64 option
}

type OrderUpdateRequest = {
    total: decimal option
    discount_applied: decimal option
    currency: string option
    payment_method: string option option
    payment_reference: string option option
    shipping_address: string option option
    tracking_number: string option option
    shipped_at: string option option
    player_id: int64 option
    coupon_id: int64 option
}

// hook: after_update
let notify_status_change (entity: OrderRow) =
    // TODO: implement notify_status_change hook
    entity

module OrderDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id, created_at, updated_at FROM orders"
        conn.Query<OrderRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id, created_at, updated_at FROM orders WHERE id = @id"
        conn.QueryFirstOrDefault<OrderRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: OrderCreateRequest) =
        let sql = "INSERT INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id) VALUES (@status, @total, @discount_applied, @currency, @payment_method, @payment_reference, @shipping_address, @tracking_number, @paid_at, @shipped_at, @player_id, @coupon_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["status"] <- box dto.status
        p.["total"] <- box dto.total
        p.["discount_applied"] <- box dto.discount_applied
        p.["currency"] <- box dto.currency
        p.["payment_method"] <- match dto.payment_method with Some v -> box v | None -> null
        p.["payment_reference"] <- match dto.payment_reference with Some v -> box v | None -> null
        p.["shipping_address"] <- match dto.shipping_address with Some v -> box v | None -> null
        p.["tracking_number"] <- match dto.tracking_number with Some v -> box v | None -> null
        p.["paid_at"] <- match dto.paid_at with Some v -> box v | None -> null
        p.["shipped_at"] <- match dto.shipped_at with Some v -> box v | None -> null
        p.["player_id"] <- box dto.player_id
        p.["coupon_id"] <- match dto.coupon_id with Some v -> box v | None -> null
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: OrderCreateRequest) =
        let sql = "UPDATE orders SET status = @status, total = @total, discount_applied = @discount_applied, currency = @currency, payment_method = @payment_method, payment_reference = @payment_reference, shipping_address = @shipping_address, tracking_number = @tracking_number, paid_at = @paid_at, shipped_at = @shipped_at, player_id = @player_id, coupon_id = @coupon_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["status"] <- box dto.status
        p.["total"] <- box dto.total
        p.["discount_applied"] <- box dto.discount_applied
        p.["currency"] <- box dto.currency
        p.["payment_method"] <- match dto.payment_method with Some v -> box v | None -> null
        p.["payment_reference"] <- match dto.payment_reference with Some v -> box v | None -> null
        p.["shipping_address"] <- match dto.shipping_address with Some v -> box v | None -> null
        p.["tracking_number"] <- match dto.tracking_number with Some v -> box v | None -> null
        p.["paid_at"] <- match dto.paid_at with Some v -> box v | None -> null
        p.["shipped_at"] <- match dto.shipped_at with Some v -> box v | None -> null
        p.["player_id"] <- box dto.player_id
        p.["coupon_id"] <- match dto.coupon_id with Some v -> box v | None -> null
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: OrderUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.total |> Option.iter (fun v -> sets.Add("total = @total"); d.["total"] <- box v)
        patch.discount_applied |> Option.iter (fun v -> sets.Add("discount_applied = @discount_applied"); d.["discount_applied"] <- box v)
        patch.currency |> Option.iter (fun v -> sets.Add("currency = @currency"); d.["currency"] <- box v)
        patch.payment_method |> Option.iter (fun v -> sets.Add("payment_method = @payment_method"); d.["payment_method"] <- match v with Some s -> box s | None -> null)
        patch.payment_reference |> Option.iter (fun v -> sets.Add("payment_reference = @payment_reference"); d.["payment_reference"] <- match v with Some s -> box s | None -> null)
        patch.shipping_address |> Option.iter (fun v -> sets.Add("shipping_address = @shipping_address"); d.["shipping_address"] <- match v with Some s -> box s | None -> null)
        patch.tracking_number |> Option.iter (fun v -> sets.Add("tracking_number = @tracking_number"); d.["tracking_number"] <- match v with Some s -> box s | None -> null)
        patch.shipped_at |> Option.iter (fun v -> sets.Add("shipped_at = @shipped_at"); d.["shipped_at"] <- match v with Some s -> box s | None -> null)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        patch.coupon_id |> Option.iter (fun v -> sets.Add("coupon_id = @coupon_id"); d.["coupon_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE orders SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM orders WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE orders SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
