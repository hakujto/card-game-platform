module cards_project.tournaments.TournamentRoundHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.TournamentRoundTypes

let validateTournamentRound (r: TournamentRoundCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.ended_at <> None)) || (Option.map2 (fun a b -> a > b) r.ended_at r.started_at |> Option.defaultValue false))) then errors.Add("Round end time must be after start time")
    if not ((not ((r.status = "Completed")) || (r.started_at <> None))) then errors.Add("Completed round must have a start time")
    if not ((r.round_number > 0)) then errors.Add("Round number must be greater than zero")
    if not ((r.time_limit_minutes > 0)) then errors.Add("Round time limit must be greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTournamentRoundHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TournamentRoundDb.getAll conn
        let dtos = rows |> List.map tournament_roundToDto
        json dtos next ctx

let getTournamentRoundHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentRoundDb.getById conn id with
        | Some row -> json (tournament_roundToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTournamentRoundHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TournamentRoundCreateRequest>()
        match validateTournamentRound dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TournamentRoundDb.create conn dto
        match TournamentRoundDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (tournament_roundToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let behaviorStartHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRoundDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement start behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCompleteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRoundDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement complete behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorGeneratePairingsHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRoundDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement generate_pairings behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsTimeExpiredHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRoundDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_time_expired behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let tournament_roundsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/tournament_rounds" >=> choose [
            GET  >=> listTournamentRoundHandler conn
            POST >=> createTournamentRoundHandler conn
        ]
        routef "/api/tournament_rounds/%d" (fun id -> choose [
            GET    >=> getTournamentRoundHandler id conn
        ])
        routef "/api/tournament_rounds/%d/api/rounds/{id}/start" (fun id -> behaviorStartHandler id conn)
        routef "/api/tournament_rounds/%d/api/rounds/{id}/complete" (fun id -> behaviorCompleteHandler id conn)
        routef "/api/tournament_rounds/%d/api/rounds/{id}/pairings" (fun id -> behaviorGeneratePairingsHandler id conn)
        routef "/api/tournament_rounds/%d/api/rounds/{id}/time-expired" (fun id -> behaviorIsTimeExpiredHandler id conn)
    ]