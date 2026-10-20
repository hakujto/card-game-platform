module cards_project.players.PlayerCollectionTypes

open System.Data

type PlayerCollectionCondition =
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
        | _ -> failwithf "Unknown PlayerCollectionCondition: %s" s

type PlayerCollectionAcquiredVia =
    | Purchase
    | Trade
    | TournamentReward
    | Pack
    | Craft

    static member ToString = function
        | Purchase -> "Purchase"
        | Trade -> "Trade"
        | TournamentReward -> "TournamentReward"
        | Pack -> "Pack"
        | Craft -> "Craft"

    static member FromString s =
        match s with
        | "Purchase" -> Purchase
        | "Trade" -> Trade
        | "TournamentReward" -> TournamentReward
        | "Pack" -> Pack
        | "Craft" -> Craft
        | _ -> failwithf "Unknown PlayerCollectionAcquiredVia: %s" s

[<CLIMutable>]
type PlayerCollectionRow = {
    Id: int64
    Quantity: int
    Foil: bool
    Condition: string
    AcquiredAt: string
    AcquiredVia: string
    PlayerId: int64
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type PlayerCollectionDto = {
    id: int64
    quantity: int
    foil: bool
    condition: string
    acquiredAt: string
    acquired_via: string
    player_id: int64
    card_id: int64
    created_at: string
    updated_at: string
}

let player_collectionToDto (r: PlayerCollectionRow) : PlayerCollectionDto = {
    id = r.Id
    quantity = r.Quantity
    foil = r.Foil
    condition = r.Condition
    acquiredAt = r.AcquiredAt
    acquired_via = r.AcquiredVia
    player_id = r.PlayerId
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type PlayerCollectionCreateRequest = {
    quantity: int
    foil: bool
    condition: string
    acquired_at: string
    acquired_via: string
    player_id: int64
    card_id: int64
}

type PlayerCollectionUpdateRequest = {
    quantity: int option
    foil: bool option
    condition: string option
    acquired_at: string option
    acquired_via: string option
    player_id: int64 option
    card_id: int64 option
}

module PlayerCollectionDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at FROM player_collections"
        conn.Query<PlayerCollectionRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at FROM player_collections WHERE id = @id"
        conn.QueryFirstOrDefault<PlayerCollectionRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: PlayerCollectionCreateRequest) =
        let sql = "INSERT INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id) VALUES (@quantity, @foil, @condition, @acquired_at, @acquired_via, @player_id, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: PlayerCollectionCreateRequest) =
        let sql = "UPDATE player_collections SET quantity = @quantity, foil = @foil, condition = @condition, acquired_at = @acquired_at, acquired_via = @acquired_via, player_id = @player_id, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: PlayerCollectionUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.quantity |> Option.iter (fun v -> sets.Add("quantity = @quantity"); d.["quantity"] <- box v)
        patch.foil |> Option.iter (fun v -> sets.Add("foil = @foil"); d.["foil"] <- box v)
        patch.condition |> Option.iter (fun v -> sets.Add("condition = @condition"); d.["condition"] <- box v)
        patch.acquired_at |> Option.iter (fun v -> sets.Add("acquired_at = @acquired_at"); d.["acquired_at"] <- box v)
        patch.acquired_via |> Option.iter (fun v -> sets.Add("acquired_via = @acquired_via"); d.["acquired_via"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE player_collections SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM player_collections WHERE id = @id"
        conn.Execute(sql, {| id = id |})
