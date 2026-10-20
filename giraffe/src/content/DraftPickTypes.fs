module cards_project.content.DraftPickTypes

open System.Data

[<CLIMutable>]
type DraftPickRow = {
    Id: int64
    PickNumber: int
    PackNumber: int
    PickedAt: string
    ParticipantId: int64
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DraftPickDto = {
    id: int64
    pick_number: int
    pack_number: int
    pickedAt: string
    participant_id: int64
    card_id: int64
    created_at: string
    updated_at: string
}

let draft_pickToDto (r: DraftPickRow) : DraftPickDto = {
    id = r.Id
    pick_number = r.PickNumber
    pack_number = r.PackNumber
    pickedAt = r.PickedAt
    participant_id = r.ParticipantId
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DraftPickCreateRequest = {
    pick_number: int
    pack_number: int
    picked_at: string
    participant_id: int64
    card_id: int64
}

type DraftPickUpdateRequest = {
    pick_number: int option
    pack_number: int option
    picked_at: string option
    participant_id: int64 option
    card_id: int64 option
}

module DraftPickDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at FROM draft_picks"
        conn.Query<DraftPickRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at FROM draft_picks WHERE id = @id"
        conn.QueryFirstOrDefault<DraftPickRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DraftPickCreateRequest) =
        let sql = "INSERT INTO draft_picks (pick_number, pack_number, picked_at, participant_id, card_id) VALUES (@pick_number, @pack_number, @picked_at, @participant_id, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: DraftPickCreateRequest) =
        let sql = "UPDATE draft_picks SET pick_number = @pick_number, pack_number = @pack_number, picked_at = @picked_at, participant_id = @participant_id, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: DraftPickUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.pick_number |> Option.iter (fun v -> sets.Add("pick_number = @pick_number"); d.["pick_number"] <- box v)
        patch.pack_number |> Option.iter (fun v -> sets.Add("pack_number = @pack_number"); d.["pack_number"] <- box v)
        patch.picked_at |> Option.iter (fun v -> sets.Add("picked_at = @picked_at"); d.["picked_at"] <- box v)
        patch.participant_id |> Option.iter (fun v -> sets.Add("participant_id = @participant_id"); d.["participant_id"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE draft_picks SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM draft_picks WHERE id = @id"
        conn.Execute(sql, {| id = id |})
