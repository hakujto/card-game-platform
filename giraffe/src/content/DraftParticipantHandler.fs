module cards_project.content.DraftParticipantHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.content.DraftParticipantTypes

let validateDraftParticipant (r: DraftParticipantCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.seat_number > 0)) then errors.Add("Seat number must be greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listDraftParticipantHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = DraftParticipantDb.getAll conn
        let dtos = rows |> List.map draft_participantToDto
        json dtos next ctx

let getDraftParticipantHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DraftParticipantDb.getById conn id with
        | Some row -> json (draft_participantToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDraftParticipantHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DraftParticipantCreateRequest>()
        match validateDraftParticipant dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = DraftParticipantDb.create conn dto
        match DraftParticipantDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (draft_participantToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let behaviorPickCardHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftParticipantDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement pick_card behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDraftedCardCountHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DraftParticipantDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement drafted_card_count behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let draft_participantsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/draft_participants" >=> choose [
            GET  >=> listDraftParticipantHandler conn
            POST >=> createDraftParticipantHandler conn
        ]
        routef "/api/draft_participants/%d" (fun id -> choose [
            GET    >=> getDraftParticipantHandler id conn
        ])
        routef "/api/draft_participants/%d/pick" (fun id -> behaviorPickCardHandler id conn)
        routef "/api/draft_participants/%d/card-count" (fun id -> behaviorDraftedCardCountHandler id conn)
    ]