module cards_project.cards.DeckTagHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.cards.DeckTagTypes

let listDeckTagHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let q = ctx.GetQueryStringValue "q" |> Result.toOption
        let rows =
            match q with
            | Some qv when qv.Length > 0 -> DeckTagDb.search conn qv
            | _ -> DeckTagDb.getAll conn
        let dtos = rows |> List.map deck_tagToDto
        json dtos next ctx

let getDeckTagHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckTagDb.getById conn id with
        | Some row -> json (deck_tagToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createDeckTagHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<DeckTagCreateRequest>()
        let newId = DeckTagDb.create conn dto
        match DeckTagDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (deck_tagToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchDeckTagHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckTagDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<DeckTagUpdateRequest>()
        DeckTagDb.patch conn id patch |> ignore
        match DeckTagDb.getById conn id with
        | Some row -> return! json (deck_tagToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deleteDeckTagHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match DeckTagDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        DeckTagDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorRenameHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckTagDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement rename behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorMergeIntoHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match DeckTagDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement merge_into behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let deck_tagsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/deck_tags" >=> choose [
            GET  >=> listDeckTagHandler conn
            POST >=> createDeckTagHandler conn
        ]
        routef "/api/deck_tags/%d" (fun id -> choose [
            GET    >=> getDeckTagHandler id conn
            PATCH  >=> patchDeckTagHandler id conn
            DELETE >=> deleteDeckTagHandler id conn
        ])
        routef "/api/deck_tags/%d/rename" (fun id -> behaviorRenameHandler id conn)
        routef "/api/deck_tags/%d/merge" (fun id -> behaviorMergeIntoHandler id conn)
    ]