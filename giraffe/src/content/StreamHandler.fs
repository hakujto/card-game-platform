module cards_project.content.StreamHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.StreamTypes

let validateStream (r: StreamCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((not ((r.actual_start <> None)) || (r.status = "Live"))) then errors.Add("actual_start_requires_live_or_ended")
    if not ((not ((r.ended_at <> None)) || (r.status = "Ended"))) then errors.Add("ended_at can only be set when stream status is Ended")
    if not ((r.viewer_count_peak >= 0)) then errors.Add("Peak viewer count must not be negative")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listStreamHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> StreamDb.search conn qv
            | _ -> StreamDb.getAll conn
        let dtos = rows |> List.map streamToDto
        json dtos next ctx

let getStreamHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match StreamDb.getById conn id with
        | Some row -> json (streamToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createStreamHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<StreamCreateRequest>()
        match validateStream dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = StreamDb.create conn dto
        match StreamDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (streamToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateStreamHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<StreamCreateRequest>()
        match validateStream dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        StreamDb.update conn id dto |> ignore
        match StreamDb.getById conn id with
        | Some row -> return! json (streamToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchStreamHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<StreamUpdateRequest>()
        StreamDb.patch conn id patch |> ignore
        match StreamDb.getById conn id with
        | Some row -> return! json (streamToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let transitionStreamHandler (id: int64) (toState: string) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // validate transition
            let validTransitions = [("Scheduled", "Live"); ("Live", "Ended"); ("Ended", "Live")]
            let current = row.Status
            if not (validTransitions |> List.exists (fun (f, t) -> f = current && t = toState)) then
                return! (setStatusCode 422 >=> json {| error = sprintf "Invalid transition %s -> %s" current toState |}) next ctx
            else
            StreamDb.setStatus conn id toState |> ignore
            return! json {| result = "ok"; status = toState |} next ctx
    }

let behaviorGoLiveHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement go_live behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorEndHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement end behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorUpdateViewerPeakHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement update_viewer_peak behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDurationMinutesHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match StreamDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement duration_minutes behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let streamsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/streams" >=> choose [
            GET  >=> listStreamHandler conn
            POST >=> createStreamHandler conn
        ]
        routef "/api/streams/%d" (fun id -> choose [
            GET    >=> getStreamHandler id conn
            PUT    >=> updateStreamHandler id conn
            PATCH  >=> patchStreamHandler id conn
        ])
        routef "/api/streams/%d/live" (fun id -> behaviorGoLiveHandler id conn)
        routef "/api/streams/%d/end" (fun id -> behaviorEndHandler id conn)
        routef "/api/streams/%d/viewers" (fun id -> behaviorUpdateViewerPeakHandler id conn)
        routef "/api/streams/%d/duration" (fun id -> behaviorDurationMinutesHandler id conn)
        routef "/api/streams/%d/transitions/%s" (fun (id, toState) -> transitionStreamHandler id toState conn)
    ]