module cards_project.players.PlayerCollectionHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.PlayerCollectionTypes

let validatePlayerCollection (r: PlayerCollectionCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.quantity > 0)) then errors.Add("Collection quantity must be greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listPlayerCollectionHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = PlayerCollectionDb.getAll conn
        let dtos = rows |> List.map player_collectionToDto
        json dtos next ctx

let getPlayerCollectionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match PlayerCollectionDb.getById conn id with
        | Some row -> json (player_collectionToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createPlayerCollectionHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<PlayerCollectionCreateRequest>()
        match validatePlayerCollection dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = PlayerCollectionDb.create conn dto
        match PlayerCollectionDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (player_collectionToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let patchPlayerCollectionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerCollectionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<PlayerCollectionUpdateRequest>()
        PlayerCollectionDb.patch conn id patch |> ignore
        match PlayerCollectionDb.getById conn id with
        | Some row -> return! json (player_collectionToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let deletePlayerCollectionHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match PlayerCollectionDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        PlayerCollectionDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorAddHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerCollectionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement add behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorRemoveHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerCollectionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement remove behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorEstimatedValueHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match PlayerCollectionDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement estimated_value behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let player_collectionsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/player_collections" >=> choose [
            GET  >=> listPlayerCollectionHandler conn
            POST >=> createPlayerCollectionHandler conn
        ]
        routef "/api/player_collections/%d" (fun id -> choose [
            GET    >=> getPlayerCollectionHandler id conn
            PATCH  >=> patchPlayerCollectionHandler id conn
            DELETE >=> deletePlayerCollectionHandler id conn
        ])
        routef "/api/player_collections/%d/api/collection/{id}/add" (fun id -> behaviorAddHandler id conn)
        routef "/api/player_collections/%d/api/collection/{id}/remove" (fun id -> behaviorRemoveHandler id conn)
        routef "/api/player_collections/%d/api/collection/{id}/value" (fun id -> behaviorEstimatedValueHandler id conn)
    ]