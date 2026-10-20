module cards_project.players.AchievementHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.AchievementTypes

let validateAchievement (r: AchievementCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.points > 0)) then errors.Add("Achievement must award at least one point")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listAchievementHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> AchievementDb.search conn qv
            | _ -> AchievementDb.getAll conn
        let dtos = rows |> List.map achievementToDto
        json dtos next ctx

let getAchievementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match AchievementDb.getById conn id with
        | Some row -> json (achievementToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createAchievementHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<AchievementCreateRequest>()
        match validateAchievement dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = AchievementDb.create conn dto
        match AchievementDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (achievementToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateAchievementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match AchievementDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<AchievementCreateRequest>()
        match validateAchievement dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        AchievementDb.update conn id dto |> ignore
        match AchievementDb.getById conn id with
        | Some row -> return! json (achievementToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchAchievementHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match AchievementDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<AchievementUpdateRequest>()
        AchievementDb.patch conn id patch |> ignore
        match AchievementDb.getById conn id with
        | Some row -> return! json (achievementToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorPointValueHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match AchievementDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement point_value behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRevealHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match AchievementDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement reveal behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let achievementsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/achievements" >=> choose [
            GET  >=> listAchievementHandler conn
            POST >=> createAchievementHandler conn
        ]
        routef "/api/achievements/%d" (fun id -> choose [
            GET    >=> getAchievementHandler id conn
            PUT    >=> updateAchievementHandler id conn
            PATCH  >=> patchAchievementHandler id conn
        ])
        routef "/api/achievements/%d/point-value" (fun id -> behaviorPointValueHandler id conn)
        routef "/api/achievements/%d/reveal" (fun id -> behaviorRevealHandler id conn)
    ]