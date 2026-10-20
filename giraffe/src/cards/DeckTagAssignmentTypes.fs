module cards_project.cards.DeckTagAssignmentTypes

open System.Data

[<CLIMutable>]
type DeckTagAssignmentRow = {
    Id: int64
    DeckId: int64
    TagId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DeckTagAssignmentDto = {
    id: int64
    deck_id: int64
    tag_id: int64
    created_at: string
    updated_at: string
}

let deck_tag_assignmentToDto (r: DeckTagAssignmentRow) : DeckTagAssignmentDto = {
    id = r.Id
    deck_id = r.DeckId
    tag_id = r.TagId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DeckTagAssignmentCreateRequest = {
    deck_id: int64
    tag_id: int64
}

type DeckTagAssignmentUpdateRequest = {
    deck_id: int64 option
    tag_id: int64 option
}

module DeckTagAssignmentDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, deck_id, tag_id, created_at, updated_at FROM deck_tag_assignments"
        conn.Query<DeckTagAssignmentRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, deck_id, tag_id, created_at, updated_at FROM deck_tag_assignments WHERE id = @id"
        conn.QueryFirstOrDefault<DeckTagAssignmentRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DeckTagAssignmentCreateRequest) =
        let sql = "INSERT INTO deck_tag_assignments (deck_id, tag_id) VALUES (@deck_id, @tag_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: DeckTagAssignmentCreateRequest) =
        let sql = "UPDATE deck_tag_assignments SET deck_id = @deck_id, tag_id = @tag_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: DeckTagAssignmentUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.deck_id |> Option.iter (fun v -> sets.Add("deck_id = @deck_id"); d.["deck_id"] <- box v)
        patch.tag_id |> Option.iter (fun v -> sets.Add("tag_id = @tag_id"); d.["tag_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE deck_tag_assignments SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM deck_tag_assignments WHERE id = @id"
        conn.Execute(sql, {| id = id |})
