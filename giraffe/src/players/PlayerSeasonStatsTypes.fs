module cards_project.players.PlayerSeasonStatsTypes

open System.Data

type PlayerSeasonStatsHighestRank =
    | Bronze
    | Silver
    | Gold
    | Platinum
    | Diamond
    | Master
    | Grandmaster

    static member ToString = function
        | Bronze -> "Bronze"
        | Silver -> "Silver"
        | Gold -> "Gold"
        | Platinum -> "Platinum"
        | Diamond -> "Diamond"
        | Master -> "Master"
        | Grandmaster -> "Grandmaster"

    static member FromString s =
        match s with
        | "Bronze" -> Bronze
        | "Silver" -> Silver
        | "Gold" -> Gold
        | "Platinum" -> Platinum
        | "Diamond" -> Diamond
        | "Master" -> Master
        | "Grandmaster" -> Grandmaster
        | _ -> failwithf "Unknown PlayerSeasonStatsHighestRank: %s" s

[<CLIMutable>]
type PlayerSeasonStatsRow = {
    Id: int64
    Wins: int
    Losses: int
    Draws: int
    TournamentWins: int
    HighestRank: string option
    SeasonPoints: int
    PlayerId: int64
    SeasonId: int64
    CreatedAt: string
    UpdatedAt: string
}

type PlayerSeasonStatsDto = {
    id: int64
    wins: int
    losses: int
    draws: int
    tournament_wins: int
    highest_rank: string option
    season_points: int
    player_id: int64
    season_id: int64
    created_at: string
    updated_at: string
}

let player_season_statsToDto (r: PlayerSeasonStatsRow) : PlayerSeasonStatsDto = {
    id = r.Id
    wins = r.Wins
    losses = r.Losses
    draws = r.Draws
    tournament_wins = r.TournamentWins
    highest_rank = r.HighestRank
    season_points = r.SeasonPoints
    player_id = r.PlayerId
    season_id = r.SeasonId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type PlayerSeasonStatsCreateRequest = {
    wins: int
    losses: int
    draws: int
    tournament_wins: int
    highest_rank: string option
    season_points: int
    player_id: int64
    season_id: int64
}

type PlayerSeasonStatsUpdateRequest = {
    wins: int option
    losses: int option
    draws: int option
    tournament_wins: int option
    highest_rank: string option option
    season_points: int option
    player_id: int64 option
    season_id: int64 option
}

module PlayerSeasonStatsDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at FROM player_season_statses"
        conn.Query<PlayerSeasonStatsRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at FROM player_season_statses WHERE id = @id"
        conn.QueryFirstOrDefault<PlayerSeasonStatsRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: PlayerSeasonStatsCreateRequest) =
        let sql = "INSERT INTO player_season_statses (wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id) VALUES (@wins, @losses, @draws, @tournament_wins, @highest_rank, @season_points, @player_id, @season_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["wins"] <- box dto.wins
        p.["losses"] <- box dto.losses
        p.["draws"] <- box dto.draws
        p.["tournament_wins"] <- box dto.tournament_wins
        p.["highest_rank"] <- match dto.highest_rank with Some v -> box v | None -> null
        p.["season_points"] <- box dto.season_points
        p.["player_id"] <- box dto.player_id
        p.["season_id"] <- box dto.season_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: PlayerSeasonStatsCreateRequest) =
        let sql = "UPDATE player_season_statses SET wins = @wins, losses = @losses, draws = @draws, tournament_wins = @tournament_wins, highest_rank = @highest_rank, season_points = @season_points, player_id = @player_id, season_id = @season_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["wins"] <- box dto.wins
        p.["losses"] <- box dto.losses
        p.["draws"] <- box dto.draws
        p.["tournament_wins"] <- box dto.tournament_wins
        p.["highest_rank"] <- match dto.highest_rank with Some v -> box v | None -> null
        p.["season_points"] <- box dto.season_points
        p.["player_id"] <- box dto.player_id
        p.["season_id"] <- box dto.season_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: PlayerSeasonStatsUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.wins |> Option.iter (fun v -> sets.Add("wins = @wins"); d.["wins"] <- box v)
        patch.losses |> Option.iter (fun v -> sets.Add("losses = @losses"); d.["losses"] <- box v)
        patch.draws |> Option.iter (fun v -> sets.Add("draws = @draws"); d.["draws"] <- box v)
        patch.tournament_wins |> Option.iter (fun v -> sets.Add("tournament_wins = @tournament_wins"); d.["tournament_wins"] <- box v)
        patch.highest_rank |> Option.iter (fun v -> sets.Add("highest_rank = @highest_rank"); d.["highest_rank"] <- match v with Some s -> box s | None -> null)
        patch.season_points |> Option.iter (fun v -> sets.Add("season_points = @season_points"); d.["season_points"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        patch.season_id |> Option.iter (fun v -> sets.Add("season_id = @season_id"); d.["season_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE player_season_statses SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM player_season_statses WHERE id = @id"
        conn.Execute(sql, {| id = id |})
