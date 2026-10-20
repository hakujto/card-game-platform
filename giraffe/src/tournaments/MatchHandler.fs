module cards_project.tournaments.MatchHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.MatchTypes

let validateMatch (r: MatchCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not (((r.player1_wins >= 0) && (r.player2_wins >= 0))) then errors.Add("Win counts must not be negative")
    if not (((r.player1_wins >= 0 && r.player1_wins <= 2) && (r.player2_wins >= 0 && r.player2_wins <= 2))) then errors.Add("Win counts cannot exceed 2 in a best-of-3 match")
    if not ((not ((r.status = "BYE")) || (r.player2_id = None))) then errors.Add("BYE match must not have a second player")
    if not ((not ((r.ended_at <> None)) || (Option.map2 (fun a b -> a > b) r.ended_at r.started_at |> Option.defaultValue false))) then errors.Add("Match end time must be after start time")
    if not ((not ((r.status = "Completed")) || (r.started_at <> None))) then errors.Add("Completed match must have a start time")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listMatchHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = MatchDb.getAll conn
        let dtos = rows |> List.map matchToDto
        json dtos next ctx

let getMatchHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match MatchDb.getById conn id with
        | Some row -> json (matchToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createMatchHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<MatchCreateRequest>()
        match validateMatch dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = MatchDb.create conn dto
        match MatchDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (matchToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let transitionMatchHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match MatchDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Pending", "Active"); ("Active", "Completed"); ("Active", "Draw"); ("Pending", "BYE"); ("Completed", "Active"); ("Draw", "Active"); ("BYE", "Active")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            MatchDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorDetermineWinnerHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match MatchDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement determine_winner behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRecordResultHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match MatchDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement record_result behavior
            return! behaviorDetermineWinnerHandler id conn next ctx
    }

let behaviorFinalizeResultHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match MatchDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement finalize_result behavior
            return! behaviorDetermineWinnerHandler id conn next ctx
    }

let behaviorConcedeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        // @guard: status = Active
        let role = ctx.GetCookieValue "role" |> Option.defaultValue ""
        if role <> "Active" then
            return! (setStatusCode 403 >=> json {| error = "Guard failed: status = Active" |}) next ctx
        else
        match MatchDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement concede behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDrawHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match MatchDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement draw behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let matchesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/matches" >=> choose [
            GET  >=> listMatchHandler conn
            POST >=> createMatchHandler conn
        ]
        routef "/api/matches/%d" (fun id -> choose [
            GET    >=> getMatchHandler id conn
        ])
        routef "/api/matches/%d/record" (fun id -> behaviorRecordResultHandler id conn)
        routef "/api/matches/%d/finalize" (fun id -> behaviorFinalizeResultHandler id conn)
        routef "/api/matches/%d/winner" (fun id -> behaviorDetermineWinnerHandler id conn)
        routef "/api/matches/%d/concede" (fun id -> behaviorConcedeHandler id conn)
        routef "/api/matches/%d/draw" (fun id -> behaviorDrawHandler id conn)
        routef "/api/matches/%d/transitions/%s" (fun (id, toState) -> transitionMatchHandler id toState conn)
    ]