module cards_project.content.DraftSessionHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.DraftSessionTypes

let validateDraftSession (r: DraftSessionCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.seats >= 2 && r.seats <= 16)) then errors.Add("Draft session must have between 2 and 16 seats")
    if not ((not ((r.completed_at <> None)) || (r.status = "Completed"))) then errors.Add("completed_at can only be set when draft status is Completed")
    if not ((r.time_per_pick_seconds > 0)) then errors.Add("Time per pick must be greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listDraftSessionHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = DraftSessionDb.getAll conn
        let dtos = rows |> List.map draft_sessionToDto
        json dtos next ctx

let getDraftSessionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DraftSessionDb.getById conn id with
        | Some row -> json (draft_sessionToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDraftSessionHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DraftSessionCreateRequest>()
        match validateDraftSession dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = DraftSessionDb.create conn dto
        match DraftSessionDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (draft_sessionToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let transitionDraftSessionHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftSessionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("WaitingForPlayers", "Drafting"); ("Drafting", "Completed"); ("Drafting", "Abandoned"); ("WaitingForPlayers", "Abandoned"); ("Completed", "Drafting"); ("Abandoned", "Drafting")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            DraftSessionDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorStartHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftSessionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement start behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorAbandonHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftSessionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement abandon behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorCompleteHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftSessionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement complete behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorIsFullHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftSessionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement is_full behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let draft_sessionsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/draft_sessions" >=> choose [
            GET  >=> listDraftSessionHandler conn
            POST >=> createDraftSessionHandler conn
        ]
        routef "/api/draft_sessions/%d" (fun id -> choose [
            GET    >=> getDraftSessionHandler id conn
        ])
        routef "/api/draft_sessions/%d/start" (fun id -> behaviorStartHandler id conn)
        routef "/api/draft_sessions/%d/abandon" (fun id -> behaviorAbandonHandler id conn)
        routef "/api/draft_sessions/%d/complete" (fun id -> behaviorCompleteHandler id conn)
        routef "/api/draft_sessions/%d/full" (fun id -> behaviorIsFullHandler id conn)
        routef "/api/draft_sessions/%d/transitions/%s" (fun (id, toState) -> transitionDraftSessionHandler id toState conn)
    ]