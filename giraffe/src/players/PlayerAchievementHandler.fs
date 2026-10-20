module cards_project.players.PlayerAchievementHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.PlayerAchievementTypes

let validatePlayerAchievement (r: PlayerAchievementCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.is_completed = true)) || (r.progress > 0))) then errors.Add("Completed achievement must have progress greater than zero")
    if not ((r.progress >= 0)) then errors.Add("Achievement progress must not be negative")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listPlayerAchievementHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = PlayerAchievementDb.getAll conn
        let dtos = rows |> List.map player_achievementToDto
        json dtos next ctx

let getPlayerAchievementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match PlayerAchievementDb.getById conn id with
        | Some row -> json (player_achievementToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let behaviorIncrementProgressHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerAchievementDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement increment_progress behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCompleteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerAchievementDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement complete behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let player_achievementsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/player_achievements" >=> choose [
            GET  >=> listPlayerAchievementHandler conn
        ]
        routef "/api/player_achievements/%d" (fun id -> choose [
            GET    >=> getPlayerAchievementHandler id conn
        ])
        routef "/api/player_achievements/%d/progress" (fun id -> behaviorIncrementProgressHandler id conn)
        routef "/api/player_achievements/%d/complete" (fun id -> behaviorCompleteHandler id conn)
    ]