module cards_project.content.DraftPickHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.DraftPickTypes

let validateDraftPick (r: DraftPickCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.pick_number > 0)) then errors.Add("Pick number must be greater than zero")
    if not ((r.pack_number >= 1 && r.pack_number <= 3)) then errors.Add("Pack number must be between 1 and 3")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listDraftPickHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = DraftPickDb.getAll conn
        let dtos = rows |> List.map draft_pickToDto
        json dtos next ctx

let getDraftPickHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DraftPickDb.getById conn id with
        | Some row -> json (draft_pickToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let behaviorIsFirstPickHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftPickDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_first_pick behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let draft_picksRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/draft_picks" >=> choose [
            GET  >=> listDraftPickHandler conn
        ]
        routef "/api/draft_picks/%d" (fun id -> choose [
            GET    >=> getDraftPickHandler id conn
        ])
        routef "/api/draft_picks/%d/first-pick" (fun id -> behaviorIsFirstPickHandler id conn)
    ]