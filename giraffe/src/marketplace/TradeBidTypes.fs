module cards_project.marketplace.TradeBidTypes

open System.Data

[<CLIMutable>]
type TradeBidRow = {
    Id: int64
    Amount: decimal
    PlacedAt: string
    IsWinning: bool
    ListingId: int64
    BidderId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TradeBidDto = {
    id: int64
    amount: decimal
    placedAt: string
    is_winning: bool
    listing_id: int64
    bidder_id: int64
    created_at: string
    updated_at: string
}

let trade_bidToDto (r: TradeBidRow) : TradeBidDto = {
    id = r.Id
    amount = r.Amount
    placedAt = r.PlacedAt
    is_winning = r.IsWinning
    listing_id = r.ListingId
    bidder_id = r.BidderId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TradeBidCreateRequest = {
    amount: decimal
    placed_at: string
    is_winning: bool
    listing_id: int64
    bidder_id: int64
}

type TradeBidUpdateRequest = {
    amount: decimal option
    placed_at: string option
    is_winning: bool option
    listing_id: int64 option
    bidder_id: int64 option
}

module TradeBidDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at FROM trade_bids"
        conn.Query<TradeBidRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at FROM trade_bids WHERE id = @id"
        conn.QueryFirstOrDefault<TradeBidRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TradeBidCreateRequest) =
        let sql = "INSERT INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id) VALUES (@amount, @placed_at, @is_winning, @listing_id, @bidder_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: TradeBidCreateRequest) =
        let sql = "UPDATE trade_bids SET amount = @amount, placed_at = @placed_at, is_winning = @is_winning, listing_id = @listing_id, bidder_id = @bidder_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: TradeBidUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.amount |> Option.iter (fun v -> sets.Add("amount = @amount"); d.["amount"] <- box v)
        patch.placed_at |> Option.iter (fun v -> sets.Add("placed_at = @placed_at"); d.["placed_at"] <- box v)
        patch.is_winning |> Option.iter (fun v -> sets.Add("is_winning = @is_winning"); d.["is_winning"] <- box v)
        patch.listing_id |> Option.iter (fun v -> sets.Add("listing_id = @listing_id"); d.["listing_id"] <- box v)
        patch.bidder_id |> Option.iter (fun v -> sets.Add("bidder_id = @bidder_id"); d.["bidder_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE trade_bids SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM trade_bids WHERE id = @id"
        conn.Execute(sql, {| id = id |})
