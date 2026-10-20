module cards_project.marketplace.CardPriceHistoryTypes

open System.Data

[<CLIMutable>]
type CardPriceHistoryRow = {
    Id: int64
    PriceDate: string
    AvgPrice: decimal
    MinPrice: decimal
    MaxPrice: decimal
    Volume: int
    Foil: bool
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type CardPriceHistoryDto = {
    id: int64
    price_date: string
    avg_price: decimal
    min_price: decimal
    max_price: decimal
    volume: int
    foil: bool
    card_id: int64
    created_at: string
    updated_at: string
}

let card_price_historyToDto (r: CardPriceHistoryRow) : CardPriceHistoryDto = {
    id = r.Id
    price_date = r.PriceDate
    avg_price = r.AvgPrice
    min_price = r.MinPrice
    max_price = r.MaxPrice
    volume = r.Volume
    foil = r.Foil
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CardPriceHistoryCreateRequest = {
    price_date: string
    avg_price: decimal
    min_price: decimal
    max_price: decimal
    volume: int
    foil: bool
    card_id: int64
}

type CardPriceHistoryUpdateRequest = {
    price_date: string option
    avg_price: decimal option
    min_price: decimal option
    max_price: decimal option
    volume: int option
    foil: bool option
    card_id: int64 option
}

module CardPriceHistoryDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at FROM card_price_histories"
        conn.Query<CardPriceHistoryRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at FROM card_price_histories WHERE id = @id"
        conn.QueryFirstOrDefault<CardPriceHistoryRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CardPriceHistoryCreateRequest) =
        let sql = "INSERT INTO card_price_histories (price_date, avg_price, min_price, max_price, volume, foil, card_id) VALUES (@price_date, @avg_price, @min_price, @max_price, @volume, @foil, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: CardPriceHistoryCreateRequest) =
        let sql = "UPDATE card_price_histories SET price_date = @price_date, avg_price = @avg_price, min_price = @min_price, max_price = @max_price, volume = @volume, foil = @foil, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: CardPriceHistoryUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.price_date |> Option.iter (fun v -> sets.Add("price_date = @price_date"); d.["price_date"] <- box v)
        patch.avg_price |> Option.iter (fun v -> sets.Add("avg_price = @avg_price"); d.["avg_price"] <- box v)
        patch.min_price |> Option.iter (fun v -> sets.Add("min_price = @min_price"); d.["min_price"] <- box v)
        patch.max_price |> Option.iter (fun v -> sets.Add("max_price = @max_price"); d.["max_price"] <- box v)
        patch.volume |> Option.iter (fun v -> sets.Add("volume = @volume"); d.["volume"] <- box v)
        patch.foil |> Option.iter (fun v -> sets.Add("foil = @foil"); d.["foil"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE card_price_histories SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM card_price_histories WHERE id = @id"
        conn.Execute(sql, {| id = id |})
