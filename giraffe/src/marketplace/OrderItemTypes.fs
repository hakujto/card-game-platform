module cards_project.marketplace.OrderItemTypes

open System.Data

[<CLIMutable>]
type OrderItemRow = {
    Id: int64
    Quantity: int
    PriceAtPurchase: decimal
    Foil: bool
    OrderId: int64
    ProductId: int64
    CreatedAt: string
    UpdatedAt: string
}

type OrderItemDto = {
    id: int64
    quantity: int
    price_at_purchase: decimal
    foil: bool
    order_id: int64
    product_id: int64
    created_at: string
    updated_at: string
}

let order_itemToDto (r: OrderItemRow) : OrderItemDto = {
    id = r.Id
    quantity = r.Quantity
    price_at_purchase = r.PriceAtPurchase
    foil = r.Foil
    order_id = r.OrderId
    product_id = r.ProductId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type OrderItemCreateRequest = {
    quantity: int
    price_at_purchase: decimal
    foil: bool
    order_id: int64
    product_id: int64
}

type OrderItemUpdateRequest = {
    quantity: int option
    price_at_purchase: decimal option
    foil: bool option
    order_id: int64 option
    product_id: int64 option
}

module OrderItemDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at FROM order_items"
        conn.Query<OrderItemRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at FROM order_items WHERE id = @id"
        conn.QueryFirstOrDefault<OrderItemRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: OrderItemCreateRequest) =
        let sql = "INSERT INTO order_items (quantity, price_at_purchase, foil, order_id, product_id) VALUES (@quantity, @price_at_purchase, @foil, @order_id, @product_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: OrderItemCreateRequest) =
        let sql = "UPDATE order_items SET quantity = @quantity, price_at_purchase = @price_at_purchase, foil = @foil, order_id = @order_id, product_id = @product_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: OrderItemUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.quantity |> Option.iter (fun v -> sets.Add("quantity = @quantity"); d.["quantity"] <- box v)
        patch.price_at_purchase |> Option.iter (fun v -> sets.Add("price_at_purchase = @price_at_purchase"); d.["price_at_purchase"] <- box v)
        patch.foil |> Option.iter (fun v -> sets.Add("foil = @foil"); d.["foil"] <- box v)
        patch.order_id |> Option.iter (fun v -> sets.Add("order_id = @order_id"); d.["order_id"] <- box v)
        patch.product_id |> Option.iter (fun v -> sets.Add("product_id = @product_id"); d.["product_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE order_items SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM order_items WHERE id = @id"
        conn.Execute(sql, {| id = id |})
