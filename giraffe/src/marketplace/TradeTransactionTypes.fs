module cards_project.marketplace.TradeTransactionTypes

open System.Data

type TradeTransactionStatus =
    | Pending
    | Completed
    | Disputed
    | Refunded

    static member ToString = function
        | Pending -> "Pending"
        | Completed -> "Completed"
        | Disputed -> "Disputed"
        | Refunded -> "Refunded"

    static member FromString s =
        match s with
        | "Pending" -> Pending
        | "Completed" -> Completed
        | "Disputed" -> Disputed
        | "Refunded" -> Refunded
        | _ -> failwithf "Unknown TradeTransactionStatus: %s" s

[<CLIMutable>]
type TradeTransactionRow = {
    Id: int64
    FinalPrice: decimal
    PlatformFee: decimal
    Status: string
    CompletedAt: string option
    ListingId: int64
    BuyerId: int64
    SellerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TradeTransactionDto = {
    id: int64
    final_price: decimal
    platform_fee: decimal
    status: string
    completedAt: string option
    listing_id: int64
    buyer_id: int64
    seller_id: int64
    created_at: string
    updated_at: string
}

let trade_transactionToDto (r: TradeTransactionRow) : TradeTransactionDto = {
    id = r.Id
    final_price = r.FinalPrice
    platform_fee = r.PlatformFee
    status = r.Status
    completedAt = r.CompletedAt
    listing_id = r.ListingId
    buyer_id = r.BuyerId
    seller_id = r.SellerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TradeTransactionCreateRequest = {
    final_price: decimal
    platform_fee: decimal
    status: string
    completed_at: string option
    listing_id: int64
    buyer_id: int64
    seller_id: int64
}

type TradeTransactionUpdateRequest = {
    final_price: decimal option
    platform_fee: decimal option
    status: string option
    completed_at: string option option
    listing_id: int64 option
    buyer_id: int64 option
    seller_id: int64 option
}

module TradeTransactionDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at FROM trade_transactions"
        conn.Query<TradeTransactionRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at FROM trade_transactions WHERE id = @id"
        conn.QueryFirstOrDefault<TradeTransactionRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TradeTransactionCreateRequest) =
        let sql = "INSERT INTO trade_transactions (final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id) VALUES (@final_price, @platform_fee, @status, @completed_at, @listing_id, @buyer_id, @seller_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["final_price"] <- box dto.final_price
        p.["platform_fee"] <- box dto.platform_fee
        p.["status"] <- box dto.status
        p.["completed_at"] <- match dto.completed_at with Some v -> box v | None -> null
        p.["listing_id"] <- box dto.listing_id
        p.["buyer_id"] <- box dto.buyer_id
        p.["seller_id"] <- box dto.seller_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TradeTransactionCreateRequest) =
        let sql = "UPDATE trade_transactions SET final_price = @final_price, platform_fee = @platform_fee, status = @status, completed_at = @completed_at, listing_id = @listing_id, buyer_id = @buyer_id, seller_id = @seller_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["final_price"] <- box dto.final_price
        p.["platform_fee"] <- box dto.platform_fee
        p.["status"] <- box dto.status
        p.["completed_at"] <- match dto.completed_at with Some v -> box v | None -> null
        p.["listing_id"] <- box dto.listing_id
        p.["buyer_id"] <- box dto.buyer_id
        p.["seller_id"] <- box dto.seller_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TradeTransactionUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.final_price |> Option.iter (fun v -> sets.Add("final_price = @final_price"); d.["final_price"] <- box v)
        patch.platform_fee |> Option.iter (fun v -> sets.Add("platform_fee = @platform_fee"); d.["platform_fee"] <- box v)
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.completed_at |> Option.iter (fun v -> sets.Add("completed_at = @completed_at"); d.["completed_at"] <- match v with Some s -> box s | None -> null)
        patch.listing_id |> Option.iter (fun v -> sets.Add("listing_id = @listing_id"); d.["listing_id"] <- box v)
        patch.buyer_id |> Option.iter (fun v -> sets.Add("buyer_id = @buyer_id"); d.["buyer_id"] <- box v)
        patch.seller_id |> Option.iter (fun v -> sets.Add("seller_id = @seller_id"); d.["seller_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE trade_transactions SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM trade_transactions WHERE id = @id"
        conn.Execute(sql, {| id = id |})
