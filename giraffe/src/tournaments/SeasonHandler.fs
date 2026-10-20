module cards_project.tournaments.SeasonHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.SeasonTypes

let validateSeason (r: SeasonCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.end_date > r.start_date)) then errors.Add("Season end date must be after start date")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listSeasonHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> SeasonDb.search conn qv
            | _ -> SeasonDb.getAll conn
        let dtos = rows |> List.map seasonToDto
        json dtos next ctx

let getSeasonHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match SeasonDb.getById conn id with
        | Some row -> json (seasonToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createSeasonHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<SeasonCreateRequest>()
        match validateSeason dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = SeasonDb.create conn dto
        match SeasonDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (seasonToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateSeasonHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match SeasonDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<SeasonCreateRequest>()
        match validateSeason dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        SeasonDb.update conn id dto |> ignore
        match SeasonDb.getById conn id with
        | Some row -> return! json (seasonToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchSeasonHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match SeasonDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<SeasonUpdateRequest>()
        SeasonDb.patch conn id patch |> ignore
        match SeasonDb.getById conn id with
        | Some row -> return! json (seasonToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorActivateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match SeasonDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement activate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDeactivateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match SeasonDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement deactivate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorFinalizeRewardsHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match SeasonDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement finalize_rewards behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsOngoingHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match SeasonDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_ongoing behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let seasonsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/seasons" >=> choose [
            GET  >=> listSeasonHandler conn
            POST >=> createSeasonHandler conn
        ]
        routef "/api/seasons/%d" (fun id -> choose [
            GET    >=> getSeasonHandler id conn
            PUT    >=> updateSeasonHandler id conn
            PATCH  >=> patchSeasonHandler id conn
        ])
        routef "/api/seasons/%d/activate" (fun id -> behaviorActivateHandler id conn)
        routef "/api/seasons/%d/deactivate" (fun id -> behaviorDeactivateHandler id conn)
        routef "/api/seasons/%d/finalize" (fun id -> behaviorFinalizeRewardsHandler id conn)
        routef "/api/seasons/%d/ongoing" (fun id -> behaviorIsOngoingHandler id conn)
    ]