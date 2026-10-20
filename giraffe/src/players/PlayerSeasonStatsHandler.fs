module cards_project.players.PlayerSeasonStatsHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.PlayerSeasonStatsTypes

let validatePlayerSeasonStats (r: PlayerSeasonStatsCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.wins >= 0)) then errors.Add("Season wins must not be negative")
    if not ((r.losses >= 0)) then errors.Add("Season losses must not be negative")
    if not ((r.tournament_wins >= 0)) then errors.Add("Season tournament wins must not be negative")
    if not ((r.season_points >= 0)) then errors.Add("Season points must not be negative")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listPlayerSeasonStatsHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = PlayerSeasonStatsDb.getAll conn
        let dtos = rows |> List.map player_season_statsToDto
        json dtos next ctx

let getPlayerSeasonStatsHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match PlayerSeasonStatsDb.getById conn id with
        | Some row -> json (player_season_statsToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let behaviorWinRateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerSeasonStatsDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement win_rate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorAddPointsHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerSeasonStatsDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement add_points behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRecordTournamentWinHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerSeasonStatsDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement record_tournament_win behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let player_season_statsesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/player_season_statses" >=> choose [
            GET  >=> listPlayerSeasonStatsHandler conn
        ]
        routef "/api/player_season_statses/%d" (fun id -> choose [
            GET    >=> getPlayerSeasonStatsHandler id conn
        ])
        routef "/api/player_season_statses/%d/api/player-season-stats/{id}/win-rate" (fun id -> behaviorWinRateHandler id conn)
        routef "/api/player_season_statses/%d/api/player-season-stats/{id}/points" (fun id -> behaviorAddPointsHandler id conn)
        routef "/api/player_season_statses/%d/api/player-season-stats/{id}/tournament-win" (fun id -> behaviorRecordTournamentWinHandler id conn)
    ]