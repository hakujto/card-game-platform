module cards_project.tournaments.TournamentPrizeHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.TournamentPrizeTypes

let validateTournamentPrize (r: TournamentPrizeCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.placement_to >= r.placement_from)) then errors.Add("placement_to must be greater than or equal to placement_from")
    if not ((r.placement_from > 0)) then errors.Add("placement_from must be greater than zero")
    if not ((r.amount >= 0)) then errors.Add("Prize amount must not be negative")
    if r.placement_from < 1 then errors.Add("placement_from must be >= 1")
    if r.placement_to < 1 then errors.Add("placement_to must be >= 1")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listTournamentPrizeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TournamentPrizeDb.getAll conn
        let dtos = rows |> List.map tournament_prizeToDto
        json dtos next ctx

let getTournamentPrizeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentPrizeDb.getById conn id with
        | Some row -> json (tournament_prizeToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTournamentPrizeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TournamentPrizeCreateRequest>()
        match validateTournamentPrize dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = TournamentPrizeDb.create conn dto
        match TournamentPrizeDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (tournament_prizeToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateTournamentPrizeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentPrizeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<TournamentPrizeCreateRequest>()
        match validateTournamentPrize dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        TournamentPrizeDb.update conn id dto |> ignore
        match TournamentPrizeDb.getById conn id with
        | Some row -> return! json (tournament_prizeToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchTournamentPrizeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentPrizeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<TournamentPrizeUpdateRequest>()
        TournamentPrizeDb.patch conn id patch |> ignore
        match TournamentPrizeDb.getById conn id with
        | Some row -> return! json (tournament_prizeToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteTournamentPrizeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentPrizeDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        TournamentPrizeDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorAppliesToPlacementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentPrizeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement applies_to_placement behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorAwardToPlayerHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentPrizeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement award_to_player behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let tournament_prizesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/tournament_prizes" >=> choose [
            GET  >=> listTournamentPrizeHandler conn
            POST >=> createTournamentPrizeHandler conn
        ]
        routef "/api/tournament_prizes/%d" (fun id -> choose [
            GET    >=> getTournamentPrizeHandler id conn
            PUT    >=> updateTournamentPrizeHandler id conn
            PATCH  >=> patchTournamentPrizeHandler id conn
            DELETE >=> deleteTournamentPrizeHandler id conn
        ])
        routef "/api/tournament_prizes/%d/api/prizes/{id}/applies" (fun id -> behaviorAppliesToPlacementHandler id conn)
        routef "/api/tournament_prizes/%d/api/prizes/{id}/award" (fun id -> behaviorAwardToPlayerHandler id conn)
    ]