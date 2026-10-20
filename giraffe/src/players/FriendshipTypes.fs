module cards_project.players.FriendshipTypes

open System.Data

type FriendshipStatus =
    | Pending
    | Accepted
    | Blocked

    static member ToString = function
        | Pending -> "Pending"
        | Accepted -> "Accepted"
        | Blocked -> "Blocked"

    static member FromString s =
        match s with
        | "Pending" -> Pending
        | "Accepted" -> Accepted
        | "Blocked" -> Blocked
        | _ -> failwithf "Unknown FriendshipStatus: %s" s

[<CLIMutable>]
type FriendshipRow = {
    Id: int64
    Status: string
    RequesterId: int64
    ReceiverId: int64
    CreatedAt: string
    UpdatedAt: string
}

type FriendshipDto = {
    id: int64
    status: string
    requester_id: int64
    receiver_id: int64
    created_at: string
    updated_at: string
}

let friendshipToDto (r: FriendshipRow) : FriendshipDto = {
    id = r.Id
    status = r.Status
    requester_id = r.RequesterId
    receiver_id = r.ReceiverId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type FriendshipCreateRequest = {
    status: string
    requester_id: int64
    receiver_id: int64
}

type FriendshipUpdateRequest = {
    status: string option
    requester_id: int64 option
    receiver_id: int64 option
}

module FriendshipDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, status, requester_id, receiver_id, created_at, updated_at FROM friendships"
        conn.Query<FriendshipRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, status, requester_id, receiver_id, created_at, updated_at FROM friendships WHERE id = @id"
        conn.QueryFirstOrDefault<FriendshipRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: FriendshipCreateRequest) =
        let sql = "INSERT INTO friendships (status, requester_id, receiver_id) VALUES (@status, @requester_id, @receiver_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: FriendshipCreateRequest) =
        let sql = "UPDATE friendships SET status = @status, requester_id = @requester_id, receiver_id = @receiver_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: FriendshipUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.requester_id |> Option.iter (fun v -> sets.Add("requester_id = @requester_id"); d.["requester_id"] <- box v)
        patch.receiver_id |> Option.iter (fun v -> sets.Add("receiver_id = @receiver_id"); d.["receiver_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE friendships SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM friendships WHERE id = @id"
        conn.Execute(sql, {| id = id |})
