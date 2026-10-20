module cards_project.tournaments.AwardedPrizeHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.tournaments.AwardedPrizeTypes

let validateAwardedPrize (r: AwardedPrizeCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.claimed = true)) || (r.claimed_at <> None))) then errors.Add("Claimed prize must have a claimed_at timestamp")
    if not ((r.final_placement > 0)) then errors.Add("Final placement must be greater than zero")
    if r.claimed = true && r.claimed_at.IsNone then errors.Add("claimed_at is required when claimed = true")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listAwardedPrizeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = AwardedPrizeDb.getAll conn
        let dtos = rows |> List.map awarded_prizeToDto
        json dtos next ctx

let getAwardedPrizeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match AwardedPrizeDb.getById conn id with
        | Some row -> json (awarded_prizeToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let behaviorClaimHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match AwardedPrizeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement claim behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let awarded_prizesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/awarded_prizes" >=> choose [
            GET  >=> listAwardedPrizeHandler conn
        ]
        routef "/api/awarded_prizes/%d" (fun id -> choose [
            GET    >=> getAwardedPrizeHandler id conn
        ])
        routef "/api/awarded_prizes/%d/claim" (fun id -> behaviorClaimHandler id conn)
    ]