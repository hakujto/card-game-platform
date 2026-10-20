module cards_project.marketplace.TradeListingTypes

open System.Data

type TradeListingStatus =
    | Active
    | Sold
    | Expired
    | Cancelled
    | Pending

    static member ToString = function
        | Active -> "Active"
        | Sold -> "Sold"
        | Expired -> "Expired"
        | Cancelled -> "Cancelled"
        | Pending -> "Pending"

    static member FromString s =
        match s with
        | "Active" -> Active
        | "Sold" -> Sold
        | "Expired" -> Expired
        | "Cancelled" -> Cancelled
        | "Pending" -> Pending
        | _ -> failwithf "Unknown TradeListingStatus: %s" s

type TradeListingListingType =
    | FixedPrice
    | Auction
    | TradeOffer

    static member ToString = function
        | FixedPrice -> "FixedPrice"
        | Auction -> "Auction"
        | TradeOffer -> "TradeOffer"

    static member FromString s =
        match s with
        | "FixedPrice" -> FixedPrice
        | "Auction" -> Auction
        | "TradeOffer" -> TradeOffer
        | _ -> failwithf "Unknown TradeListingListingType: %s" s

type TradeListingCondition =
    | Mint
    | NearMint
    | Excellent
    | Good
    | Played

    static member ToString = function
        | Mint -> "Mint"
        | NearMint -> "NearMint"
        | Excellent -> "Excellent"
        | Good -> "Good"
        | Played -> "Played"

    static member FromString s =
        match s with
        | "Mint" -> Mint
        | "NearMint" -> NearMint
        | "Excellent" -> Excellent
        | "Good" -> Good
        | "Played" -> Played
        | _ -> failwithf "Unknown TradeListingCondition: %s" s

[<CLIMutable>]
type TradeListingRow = {
    Id: int64
    PublicId: string
    Status: string
    ListingType: string
    AskingPrice: decimal option
    AuctionStartPrice: decimal option
    AuctionCurrentBid: decimal option
    AuctionEndTime: string option
    Foil: bool
    Condition: string
    Quantity: int
    Description: string option
    ExpiresAt: string option
    SellerId: int64
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TradeListingDto = {
    id: int64
    public_id: string
    status: string
    listing_type: string
    asking_price: decimal option
    auction_start_price: decimal option
    auction_current_bid: decimal option
    auctionEndTime: string option
    foil: bool
    condition: string
    quantity: int
    description: string option
    expiresAt: string option
    seller_id: int64
    card_id: int64
    created_at: string
    updated_at: string
}

let trade_listingToDto (r: TradeListingRow) : TradeListingDto = {
    id = r.Id
    public_id = r.PublicId
    status = r.Status
    listing_type = r.ListingType
    asking_price = r.AskingPrice
    auction_start_price = r.AuctionStartPrice
    auction_current_bid = r.AuctionCurrentBid
    auctionEndTime = r.AuctionEndTime
    foil = r.Foil
    condition = r.Condition
    quantity = r.Quantity
    description = r.Description
    expiresAt = r.ExpiresAt
    seller_id = r.SellerId
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TradeListingCreateRequest = {
    public_id: string
    status: string
    listing_type: string
    asking_price: decimal option
    auction_start_price: decimal option
    auction_current_bid: decimal option
    auction_end_time: string option
    foil: bool
    condition: string
    quantity: int
    description: string option
    expires_at: string option
    seller_id: int64
    card_id: int64
}

type TradeListingUpdateRequest = {
    public_id: string option
    listing_type: string option
    asking_price: decimal option option
    auction_start_price: decimal option option
    auction_current_bid: decimal option option
    auction_end_time: string option option
    foil: bool option
    condition: string option
    quantity: int option
    description: string option option
    expires_at: string option option
    seller_id: int64 option
    card_id: int64 option
}

module TradeListingDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings"
        conn.Query<TradeListingRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings WHERE description LIKE @q"
        conn.Query<TradeListingRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings WHERE id = @id"
        conn.QueryFirstOrDefault<TradeListingRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TradeListingCreateRequest) =
        let sql = "INSERT INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id) VALUES (@public_id, @status, @listing_type, @asking_price, @auction_start_price, @auction_current_bid, @auction_end_time, @foil, @condition, @quantity, @description, @expires_at, @seller_id, @card_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["public_id"] <- box dto.public_id
        p.["status"] <- box dto.status
        p.["listing_type"] <- box dto.listing_type
        p.["asking_price"] <- match dto.asking_price with Some v -> box v | None -> null
        p.["auction_start_price"] <- match dto.auction_start_price with Some v -> box v | None -> null
        p.["auction_current_bid"] <- match dto.auction_current_bid with Some v -> box v | None -> null
        p.["auction_end_time"] <- match dto.auction_end_time with Some v -> box v | None -> null
        p.["foil"] <- box dto.foil
        p.["condition"] <- box dto.condition
        p.["quantity"] <- box dto.quantity
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["expires_at"] <- match dto.expires_at with Some v -> box v | None -> null
        p.["seller_id"] <- box dto.seller_id
        p.["card_id"] <- box dto.card_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TradeListingCreateRequest) =
        let sql = "UPDATE trade_listings SET public_id = @public_id, status = @status, listing_type = @listing_type, asking_price = @asking_price, auction_start_price = @auction_start_price, auction_current_bid = @auction_current_bid, auction_end_time = @auction_end_time, foil = @foil, condition = @condition, quantity = @quantity, description = @description, expires_at = @expires_at, seller_id = @seller_id, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["public_id"] <- box dto.public_id
        p.["status"] <- box dto.status
        p.["listing_type"] <- box dto.listing_type
        p.["asking_price"] <- match dto.asking_price with Some v -> box v | None -> null
        p.["auction_start_price"] <- match dto.auction_start_price with Some v -> box v | None -> null
        p.["auction_current_bid"] <- match dto.auction_current_bid with Some v -> box v | None -> null
        p.["auction_end_time"] <- match dto.auction_end_time with Some v -> box v | None -> null
        p.["foil"] <- box dto.foil
        p.["condition"] <- box dto.condition
        p.["quantity"] <- box dto.quantity
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["expires_at"] <- match dto.expires_at with Some v -> box v | None -> null
        p.["seller_id"] <- box dto.seller_id
        p.["card_id"] <- box dto.card_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TradeListingUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.public_id |> Option.iter (fun v -> sets.Add("public_id = @public_id"); d.["public_id"] <- box v)
        patch.listing_type |> Option.iter (fun v -> sets.Add("listing_type = @listing_type"); d.["listing_type"] <- box v)
        patch.asking_price |> Option.iter (fun v -> sets.Add("asking_price = @asking_price"); d.["asking_price"] <- match v with Some s -> box s | None -> null)
        patch.auction_start_price |> Option.iter (fun v -> sets.Add("auction_start_price = @auction_start_price"); d.["auction_start_price"] <- match v with Some s -> box s | None -> null)
        patch.auction_current_bid |> Option.iter (fun v -> sets.Add("auction_current_bid = @auction_current_bid"); d.["auction_current_bid"] <- match v with Some s -> box s | None -> null)
        patch.auction_end_time |> Option.iter (fun v -> sets.Add("auction_end_time = @auction_end_time"); d.["auction_end_time"] <- match v with Some s -> box s | None -> null)
        patch.foil |> Option.iter (fun v -> sets.Add("foil = @foil"); d.["foil"] <- box v)
        patch.condition |> Option.iter (fun v -> sets.Add("condition = @condition"); d.["condition"] <- box v)
        patch.quantity |> Option.iter (fun v -> sets.Add("quantity = @quantity"); d.["quantity"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- match v with Some s -> box s | None -> null)
        patch.expires_at |> Option.iter (fun v -> sets.Add("expires_at = @expires_at"); d.["expires_at"] <- match v with Some s -> box s | None -> null)
        patch.seller_id |> Option.iter (fun v -> sets.Add("seller_id = @seller_id"); d.["seller_id"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE trade_listings SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM trade_listings WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE trade_listings SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
