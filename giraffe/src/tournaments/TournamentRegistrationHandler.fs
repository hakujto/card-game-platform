module cards_project.tournaments.TournamentRegistrationHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.TournamentRegistrationTypes

let validateTournamentRegistration (r: TournamentRegistrationCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.points_earned >= 0)) then errors.Add("Points earned must not be negative")
    if not ((not ((r.final_standing <> None)) || (r.final_standing |> Option.map (fun v -> v > 0) |> Option.defaultValue false))) then errors.Add("Final standing must be greater than zero")
    if not ((not ((r.seed <> None)) || (r.seed |> Option.map (fun v -> v > 0) |> Option.defaultValue false))) then errors.Add("Seed must be greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTournamentRegistrationHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TournamentRegistrationDb.getAll conn
        let dtos = rows |> List.map tournament_registrationToDto
        json dtos next ctx

let getTournamentRegistrationHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentRegistrationDb.getById conn id with
        | Some row -> json (tournament_registrationToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTournamentRegistrationHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TournamentRegistrationCreateRequest>()
        match validateTournamentRegistration dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TournamentRegistrationDb.create conn dto
        match TournamentRegistrationDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (tournament_registrationToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let behaviorWithdrawHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRegistrationDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement withdraw behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDisqualifyHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRegistrationDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement disqualify behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorPromoteFromWaitlistHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentRegistrationDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement promote_from_waitlist behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let tournament_registrationsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/tournament_registrations" >=> choose [
            GET  >=> listTournamentRegistrationHandler conn
            POST >=> createTournamentRegistrationHandler conn
        ]
        routef "/api/tournament_registrations/%d" (fun id -> choose [
            GET    >=> getTournamentRegistrationHandler id conn
        ])
        routef "/api/tournament_registrations/%d/api/registrations/{id}/withdraw" (fun id -> behaviorWithdrawHandler id conn)
        routef "/api/tournament_registrations/%d/api/registrations/{id}/disqualify" (fun id -> behaviorDisqualifyHandler id conn)
        routef "/api/tournament_registrations/%d/api/registrations/{id}/promote" (fun id -> behaviorPromoteFromWaitlistHandler id conn)
    ]