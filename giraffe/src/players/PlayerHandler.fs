module cards_project.players.PlayerHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.PlayerTypes

let validatePlayer (r: PlayerCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.rating >= 0 && r.rating <= 9999)) then errors.Add("Rating must be between 0 and 9999")
    if not ((r.peak_rating >= r.rating)) then errors.Add("Peak rating must be greater than or equal to current rating")
    r.country_code |> Option.iter (fun v -> if not (System.Text.RegularExpressions.Regex.IsMatch(v, @"[A-Z]{2}")) then errors.Add("country_code must match pattern [A-Z]{2}"))
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listPlayerHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> PlayerDb.search conn qv
            | _ -> PlayerDb.getAll conn
        let dtos = rows |> List.map playerToDto
        json dtos next ctx

let getPlayerHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match PlayerDb.getById conn id with
        | Some row -> json (playerToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createPlayerHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<PlayerCreateRequest>()
        match validatePlayer dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = PlayerDb.create conn dto
        match PlayerDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (playerToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchPlayerHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<PlayerPatchRequest>()
        PlayerDb.patch conn id patch |> ignore
        match PlayerDb.getById conn id with
        | Some row -> return! json (playerToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorPromoteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement promote behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDemoteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement demote behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRecordWinHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement record_win behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRecordLossHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement record_loss behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorWinRateHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement win_rate behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorVerifyHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement verify behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUpdateRatingHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement update_rating behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let playersRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/players" >=> choose [
            GET  >=> listPlayerHandler conn
            POST >=> createPlayerHandler conn
        ]
        routef "/api/players/%d" (fun id -> choose [
            GET    >=> getPlayerHandler id conn
            PATCH  >=> patchPlayerHandler id conn
        ])
        routef "/api/players/%d/promote" (fun id -> behaviorPromoteHandler id conn)
        routef "/api/players/%d/demote" (fun id -> behaviorDemoteHandler id conn)
        routef "/api/players/%d/win" (fun id -> behaviorRecordWinHandler id conn)
        routef "/api/players/%d/loss" (fun id -> behaviorRecordLossHandler id conn)
        routef "/api/players/%d/win-rate" (fun id -> behaviorWinRateHandler id conn)
        routef "/api/players/%d/verify" (fun id -> behaviorVerifyHandler id conn)
        routef "/api/players/%d/rating" (fun id -> behaviorUpdateRatingHandler id conn)
    ]