module cards_project.content.DraftParticipantTypes

open System.Data

[<CLIMutable>]
type DraftParticipantRow = {
    Id: int64
    SeatNumber: int
    JoinedAt: string
    SessionId: int64
    PlayerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DraftParticipantDto = {
    id: int64
    seat_number: int
    joinedAt: string
    session_id: int64
    player_id: int64
    created_at: string
    updated_at: string
}

let draft_participantToDto (r: DraftParticipantRow) : DraftParticipantDto = {
    id = r.Id
    seat_number = r.SeatNumber
    joinedAt = r.JoinedAt
    session_id = r.SessionId
    player_id = r.PlayerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DraftParticipantCreateRequest = {
    seat_number: int
    joined_at: string
    session_id: int64
    player_id: int64
}

type DraftParticipantUpdateRequest = {
    seat_number: int option
    joined_at: string option
    session_id: int64 option
    player_id: int64 option
}

module DraftParticipantDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, seat_number, joined_at, session_id, player_id, created_at, updated_at FROM draft_participants"
        conn.Query<DraftParticipantRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, seat_number, joined_at, session_id, player_id, created_at, updated_at FROM draft_participants WHERE id = @id"
        conn.QueryFirstOrDefault<DraftParticipantRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DraftParticipantCreateRequest) =
        let sql = "INSERT INTO draft_participants (seat_number, joined_at, session_id, player_id) VALUES (@seat_number, @joined_at, @session_id, @player_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: DraftParticipantCreateRequest) =
        let sql = "UPDATE draft_participants SET seat_number = @seat_number, joined_at = @joined_at, session_id = @session_id, player_id = @player_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: DraftParticipantUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.seat_number |> Option.iter (fun v -> sets.Add("seat_number = @seat_number"); d.["seat_number"] <- box v)
        patch.joined_at |> Option.iter (fun v -> sets.Add("joined_at = @joined_at"); d.["joined_at"] <- box v)
        patch.session_id |> Option.iter (fun v -> sets.Add("session_id = @session_id"); d.["session_id"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE draft_participants SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM draft_participants WHERE id = @id"
        conn.Execute(sql, {| id = id |})
