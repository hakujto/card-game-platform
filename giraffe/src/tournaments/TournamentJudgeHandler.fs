module cards_project.tournaments.TournamentJudgeHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.TournamentJudgeTypes

let listTournamentJudgeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = TournamentJudgeDb.getAll conn
        let dtos = rows |> List.map tournament_judgeToDto
        json dtos next ctx

let getTournamentJudgeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentJudgeDb.getById conn id with
        | Some row -> json (tournament_judgeToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createTournamentJudgeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<TournamentJudgeCreateRequest>()
        let newId = TournamentJudgeDb.create conn dto
        match TournamentJudgeDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (tournament_judgeToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteTournamentJudgeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match TournamentJudgeDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        TournamentJudgeDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorPromoteToHeadHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentJudgeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement promote_to_head behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRemoveHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match TournamentJudgeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement remove behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let tournament_judgesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/tournament_judges" >=> choose [
            GET  >=> listTournamentJudgeHandler conn
            POST >=> createTournamentJudgeHandler conn
        ]
        routef "/api/tournament_judges/%d" (fun id -> choose [
            GET    >=> getTournamentJudgeHandler id conn
            DELETE >=> deleteTournamentJudgeHandler id conn
        ])
        routef "/api/tournament_judges/%d/promote" (fun id -> behaviorPromoteToHeadHandler id conn)
    ]