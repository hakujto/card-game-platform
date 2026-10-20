module cards_project.content.DraftSessionTypes

open System.Data

type DraftSessionStatus =
    | WaitingForPlayers
    | Drafting
    | Completed
    | Abandoned

    static member ToString = function
        | WaitingForPlayers -> "WaitingForPlayers"
        | Drafting -> "Drafting"
        | Completed -> "Completed"
        | Abandoned -> "Abandoned"

    static member FromString s =
        match s with
        | "WaitingForPlayers" -> WaitingForPlayers
        | "Drafting" -> Drafting
        | "Completed" -> Completed
        | "Abandoned" -> Abandoned
        | _ -> failwithf "Unknown DraftSessionStatus: %s" s

type DraftSessionDraftType =
    | Booster
    | Cube
    | Rochester

    static member ToString = function
        | Booster -> "Booster"
        | Cube -> "Cube"
        | Rochester -> "Rochester"

    static member FromString s =
        match s with
        | "Booster" -> Booster
        | "Cube" -> Cube
        | "Rochester" -> Rochester
        | _ -> failwithf "Unknown DraftSessionDraftType: %s" s

[<CLIMutable>]
type DraftSessionRow = {
    Id: int64
    Status: string
    DraftType: string
    PackContents: string option
    Seats: int
    TimePerPickSeconds: int
    CompletedAt: string option
    CardSetId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DraftSessionDto = {
    id: int64
    status: string
    draft_type: string
    pack_contents: string option
    seats: int
    time_per_pick_seconds: int
    completedAt: string option
    card_set_id: int64
    created_at: string
    updated_at: string
}

let draft_sessionToDto (r: DraftSessionRow) : DraftSessionDto = {
    id = r.Id
    status = r.Status
    draft_type = r.DraftType
    pack_contents = r.PackContents
    seats = r.Seats
    time_per_pick_seconds = r.TimePerPickSeconds
    completedAt = r.CompletedAt
    card_set_id = r.CardSetId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DraftSessionCreateRequest = {
    status: string
    draft_type: string
    pack_contents: string option
    seats: int
    time_per_pick_seconds: int
    completed_at: string option
    card_set_id: int64
}

type DraftSessionUpdateRequest = {
    status: string option
    draft_type: string option
    pack_contents: string option option
    seats: int option
    time_per_pick_seconds: int option
    completed_at: string option option
    card_set_id: int64 option
}

module DraftSessionDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, status, draft_type, pack_contents, seats, time_per_pick_seconds, completed_at, card_set_id, created_at, updated_at FROM draft_sessions"
        conn.Query<DraftSessionRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, status, draft_type, pack_contents, seats, time_per_pick_seconds, completed_at, card_set_id, created_at, updated_at FROM draft_sessions WHERE id = @id"
        conn.QueryFirstOrDefault<DraftSessionRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DraftSessionCreateRequest) =
        let sql = "INSERT INTO draft_sessions (status, draft_type, pack_contents, seats, time_per_pick_seconds, completed_at, card_set_id) VALUES (@status, @draft_type, @pack_contents, @seats, @time_per_pick_seconds, @completed_at, @card_set_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["status"] <- box dto.status
        p.["draft_type"] <- box dto.draft_type
        p.["pack_contents"] <- match dto.pack_contents with Some v -> box v | None -> null
        p.["seats"] <- box dto.seats
        p.["time_per_pick_seconds"] <- box dto.time_per_pick_seconds
        p.["completed_at"] <- match dto.completed_at with Some v -> box v | None -> null
        p.["card_set_id"] <- box dto.card_set_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: DraftSessionCreateRequest) =
        let sql = "UPDATE draft_sessions SET status = @status, draft_type = @draft_type, pack_contents = @pack_contents, seats = @seats, time_per_pick_seconds = @time_per_pick_seconds, completed_at = @completed_at, card_set_id = @card_set_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["status"] <- box dto.status
        p.["draft_type"] <- box dto.draft_type
        p.["pack_contents"] <- match dto.pack_contents with Some v -> box v | None -> null
        p.["seats"] <- box dto.seats
        p.["time_per_pick_seconds"] <- box dto.time_per_pick_seconds
        p.["completed_at"] <- match dto.completed_at with Some v -> box v | None -> null
        p.["card_set_id"] <- box dto.card_set_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: DraftSessionUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.status |> Option.iter (fun v -> sets.Add("status = @status"); d.["status"] <- box v)
        patch.draft_type |> Option.iter (fun v -> sets.Add("draft_type = @draft_type"); d.["draft_type"] <- box v)
        patch.pack_contents |> Option.iter (fun v -> sets.Add("pack_contents = @pack_contents"); d.["pack_contents"] <- match v with Some s -> box s | None -> null)
        patch.seats |> Option.iter (fun v -> sets.Add("seats = @seats"); d.["seats"] <- box v)
        patch.time_per_pick_seconds |> Option.iter (fun v -> sets.Add("time_per_pick_seconds = @time_per_pick_seconds"); d.["time_per_pick_seconds"] <- box v)
        patch.completed_at |> Option.iter (fun v -> sets.Add("completed_at = @completed_at"); d.["completed_at"] <- match v with Some s -> box s | None -> null)
        patch.card_set_id |> Option.iter (fun v -> sets.Add("card_set_id = @card_set_id"); d.["card_set_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE draft_sessions SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM draft_sessions WHERE id = @id"
        conn.Execute(sql, {| id = id |})

    let setStatus (conn: IDbConnection) (id: int64) (status: string) =
        let sql = "UPDATE draft_sessions SET status = @status, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| id = id; status = status |})
