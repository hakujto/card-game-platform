module cards_project.tournaments.TournamentPrizeTypes

open System.Data

type TournamentPrizePrizeType =
    | Currency
    | Cards
    | BoosterPacks
    | Trophy
    | SeasonPoints
    | Mixed

    static member ToString = function
        | Currency -> "Currency"
        | Cards -> "Cards"
        | BoosterPacks -> "BoosterPacks"
        | Trophy -> "Trophy"
        | SeasonPoints -> "SeasonPoints"
        | Mixed -> "Mixed"

    static member FromString s =
        match s with
        | "Currency" -> Currency
        | "Cards" -> Cards
        | "BoosterPacks" -> BoosterPacks
        | "Trophy" -> Trophy
        | "SeasonPoints" -> SeasonPoints
        | "Mixed" -> Mixed
        | _ -> failwithf "Unknown TournamentPrizePrizeType: %s" s

[<CLIMutable>]
type TournamentPrizeRow = {
    Id: int64
    PlacementFrom: int
    PlacementTo: int
    PrizeType: string
    Amount: decimal
    Description: string option
    PacksCount: int64 option
    SeasonPoints: int
    TournamentId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TournamentPrizeDto = {
    id: int64
    placement_from: int
    placement_to: int
    prize_type: string
    amount: decimal
    description: string option
    packs_count: int option
    season_points: int
    tournament_id: int64
    created_at: string
    updated_at: string
}

let tournament_prizeToDto (r: TournamentPrizeRow) : TournamentPrizeDto = {
    id = r.Id
    placement_from = r.PlacementFrom
    placement_to = r.PlacementTo
    prize_type = r.PrizeType
    amount = r.Amount
    description = r.Description
    packs_count = r.PacksCount |> Option.map int
    season_points = r.SeasonPoints
    tournament_id = r.TournamentId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TournamentPrizeCreateRequest = {
    placement_from: int
    placement_to: int
    prize_type: string
    amount: decimal
    description: string option
    packs_count: int option
    season_points: int
    tournament_id: int64
}

type TournamentPrizeUpdateRequest = {
    placement_from: int option
    placement_to: int option
    prize_type: string option
    amount: decimal option
    description: string option option
    packs_count: int option option
    season_points: int option
    tournament_id: int64 option
}

module TournamentPrizeDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at FROM tournament_prizes"
        conn.Query<TournamentPrizeRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at FROM tournament_prizes WHERE id = @id"
        conn.QueryFirstOrDefault<TournamentPrizeRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TournamentPrizeCreateRequest) =
        let sql = "INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (@placement_from, @placement_to, @prize_type, @amount, @description, @packs_count, @season_points, @tournament_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["placement_from"] <- box dto.placement_from
        p.["placement_to"] <- box dto.placement_to
        p.["prize_type"] <- box dto.prize_type
        p.["amount"] <- box dto.amount
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["packs_count"] <- match dto.packs_count with Some v -> box v | None -> null
        p.["season_points"] <- box dto.season_points
        p.["tournament_id"] <- box dto.tournament_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: TournamentPrizeCreateRequest) =
        let sql = "UPDATE tournament_prizes SET placement_from = @placement_from, placement_to = @placement_to, prize_type = @prize_type, amount = @amount, description = @description, packs_count = @packs_count, season_points = @season_points, tournament_id = @tournament_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["placement_from"] <- box dto.placement_from
        p.["placement_to"] <- box dto.placement_to
        p.["prize_type"] <- box dto.prize_type
        p.["amount"] <- box dto.amount
        p.["description"] <- match dto.description with Some v -> box v | None -> null
        p.["packs_count"] <- match dto.packs_count with Some v -> box v | None -> null
        p.["season_points"] <- box dto.season_points
        p.["tournament_id"] <- box dto.tournament_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: TournamentPrizeUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.placement_from |> Option.iter (fun v -> sets.Add("placement_from = @placement_from"); d.["placement_from"] <- box v)
        patch.placement_to |> Option.iter (fun v -> sets.Add("placement_to = @placement_to"); d.["placement_to"] <- box v)
        patch.prize_type |> Option.iter (fun v -> sets.Add("prize_type = @prize_type"); d.["prize_type"] <- box v)
        patch.amount |> Option.iter (fun v -> sets.Add("amount = @amount"); d.["amount"] <- box v)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- match v with Some s -> box s | None -> null)
        patch.packs_count |> Option.iter (fun v -> sets.Add("packs_count = @packs_count"); d.["packs_count"] <- match v with Some s -> box s | None -> null)
        patch.season_points |> Option.iter (fun v -> sets.Add("season_points = @season_points"); d.["season_points"] <- box v)
        patch.tournament_id |> Option.iter (fun v -> sets.Add("tournament_id = @tournament_id"); d.["tournament_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE tournament_prizes SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM tournament_prizes WHERE id = @id"
        conn.Execute(sql, {| id = id |})
