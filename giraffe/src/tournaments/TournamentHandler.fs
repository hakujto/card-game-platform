module cards_project.tournaments.TournamentHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.TournamentTypes

let validateTournament (r: TournamentCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.max_players >= 2 && r.max_players <= 512)) then errors.Add("Tournament must allow between 2 and 512 players")
    if not ((r.entry_fee >= 0)) then errors.Add("Entry fee must not be negative")
    if not ((r.prize_pool >= 0)) then errors.Add("Prize pool must not be negative")
    if not ((not ((r.end_time <> None)) || (r.end_time > Some r.start_time))) then errors.Add("End time must be after start time")
    if r.max_players < 2 then errors.Add("max_players must be >= 2")
    if r.max_players > 512 then errors.Add("max_players must be <= 512")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTournamentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> TournamentDb.search conn qv
            | _ -> TournamentDb.getAll conn
        let dtos = rows |> List.map tournamentToDto
        json dtos next ctx

let getTournamentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentDb.getById conn id with
        | Some row -> json (tournamentToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTournamentHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TournamentCreateRequest>()
        match validateTournament dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TournamentDb.create conn dto
        match TournamentDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (tournamentToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateTournamentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<TournamentCreateRequest>()
        match validateTournament dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        TournamentDb.update conn id dto |> ignore
        match TournamentDb.getById conn id with
        | Some row -> return! json (tournamentToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchTournamentHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<TournamentPatchRequest>()
        TournamentDb.patch conn id patch |> ignore
        match TournamentDb.getById conn id with
        | Some row -> return! json (tournamentToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let transitionTournamentHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Draft", "Registration"); ("Registration", "Ongoing"); ("Registration", "Cancelled"); ("Ongoing", "Completed"); ("Ongoing", "Cancelled"); ("Completed", "Draft"); ("Cancelled", "Draft")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            TournamentDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorStartHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement start behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCancelHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement cancel behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCompleteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement complete behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorGenerateRoundHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement generate_round behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCalculatePrizeDistributionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement calculate_prize_distribution behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRegisterPlayerHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement register_player behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsFullHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_full behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let tournamentsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/tournaments" >=> choose [
            GET  >=> listTournamentHandler conn
            POST >=> createTournamentHandler conn
        ]
        routef "/api/tournaments/%d" (fun id -> choose [
            GET    >=> getTournamentHandler id conn
            PUT    >=> updateTournamentHandler id conn
            PATCH  >=> patchTournamentHandler id conn
        ])
        routef "/api/tournaments/%d/start" (fun id -> behaviorStartHandler id conn)
        routef "/api/tournaments/%d/cancel" (fun id -> behaviorCancelHandler id conn)
        routef "/api/tournaments/%d/complete" (fun id -> behaviorCompleteHandler id conn)
        routef "/api/tournaments/%d/rounds" (fun id -> behaviorGenerateRoundHandler id conn)
        routef "/api/tournaments/%d/prizes" (fun id -> behaviorCalculatePrizeDistributionHandler id conn)
        routef "/api/tournaments/%d/register" (fun id -> behaviorRegisterPlayerHandler id conn)
        routef "/api/tournaments/%d/full" (fun id -> behaviorIsFullHandler id conn)
        routef "/api/tournaments/%d/transitions/%s" (fun (id, toState) -> transitionTournamentHandler id toState conn)
    ]