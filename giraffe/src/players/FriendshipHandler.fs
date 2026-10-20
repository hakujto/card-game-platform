module cards_project.players.FriendshipHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.FriendshipTypes

let listFriendshipHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = FriendshipDb.getAll conn
        let dtos = rows |> List.map friendshipToDto
        json dtos next ctx

let getFriendshipHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match FriendshipDb.getById conn id with
        | Some row -> json (friendshipToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createFriendshipHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<FriendshipCreateRequest>()
        let newId = FriendshipDb.create conn dto
        match FriendshipDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (friendshipToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteFriendshipHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match FriendshipDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        FriendshipDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let behaviorAcceptHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match FriendshipDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement accept behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDeclineHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match FriendshipDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement decline behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorBlockHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match FriendshipDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement block behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let friendshipsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/friendships" >=> choose [
            GET  >=> listFriendshipHandler conn
            POST >=> createFriendshipHandler conn
        ]
        routef "/api/friendships/%d" (fun id -> choose [
            GET    >=> getFriendshipHandler id conn
            DELETE >=> deleteFriendshipHandler id conn
        ])
        routef "/api/friendships/%d/accept" (fun id -> behaviorAcceptHandler id conn)
        routef "/api/friendships/%d/decline" (fun id -> behaviorDeclineHandler id conn)
        routef "/api/friendships/%d/block" (fun id -> behaviorBlockHandler id conn)
    ]