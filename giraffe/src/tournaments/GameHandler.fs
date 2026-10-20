module cards_project.tournaments.GameHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.GameTypes

let validateGame (r: GameCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.game_number >= 1 && r.game_number <= 3)) then errors.Add("Game number must be between 1 and 3 (best-of-3)")
    if not ((not ((r.turns_played <> None)) || (r.turns_played |> Option.map (fun v -> v > 0) |> Option.defaultValue false))) then errors.Add("Turns played must be greater than zero")
    if not ((not ((r.duration_seconds <> None)) || (r.duration_seconds |> Option.map (fun v -> v > 0) |> Option.defaultValue false))) then errors.Add("Game duration must be greater than zero")
    if not ((not ((r.winner_side = Some "Draw")) || (r.winner_id = None))) then errors.Add("A draw cannot have a winner")
    if not ((not (((r.winner_side <> None) && (r.winner_side = Some "Draw"))) || (r.winner_id <> None))) then errors.Add("A decisive game must have a winner player set")
    if r.game_number < 1 then errors.Add("game_number must be >= 1")
    if r.game_number > 3 then errors.Add("game_number must be <= 3")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listGameHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = GameDb.getAll conn
        let dtos = rows |> List.map gameToDto
        json dtos next ctx

let getGameHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match GameDb.getById conn id with
        | Some row -> json (gameToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createGameHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<GameCreateRequest>()
        match validateGame dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = GameDb.create conn dto
        match GameDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (gameToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let behaviorRecordWinnerHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match GameDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement record_winner behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDurationMinutesHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match GameDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement duration_minutes behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let gamesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/games" >=> choose [
            GET  >=> listGameHandler conn
            POST >=> createGameHandler conn
        ]
        routef "/api/games/%d" (fun id -> choose [
            GET    >=> getGameHandler id conn
        ])
        routef "/api/games/%d/winner" (fun id -> behaviorRecordWinnerHandler id conn)
        routef "/api/games/%d/duration" (fun id -> behaviorDurationMinutesHandler id conn)
    ]