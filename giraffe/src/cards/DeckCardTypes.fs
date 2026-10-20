module cards_project.cards.DeckCardTypes

open System.Data

[<CLIMutable>]
type DeckCardRow = {
    Id: int64
    Quantity: int
    IsCommander: bool
    DeckId: int64
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DeckCardDto = {
    id: int64
    quantity: int
    is_commander: bool
    deck_id: int64
    card_id: int64
    created_at: string
    updated_at: string
}

let deck_cardToDto (r: DeckCardRow) : DeckCardDto = {
    id = r.Id
    quantity = r.Quantity
    is_commander = r.IsCommander
    deck_id = r.DeckId
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DeckCardCreateRequest = {
    quantity: int
    is_commander: bool
    deck_id: int64
    card_id: int64
}

type DeckCardUpdateRequest = {
    quantity: int option
    is_commander: bool option
    deck_id: int64 option
    card_id: int64 option
}

module DeckCardDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, quantity, is_commander, deck_id, card_id, created_at, updated_at FROM deck_cards"
        conn.Query<DeckCardRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, quantity, is_commander, deck_id, card_id, created_at, updated_at FROM deck_cards WHERE id = @id"
        conn.QueryFirstOrDefault<DeckCardRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DeckCardCreateRequest) =
        let sql = "INSERT INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (@quantity, @is_commander, @deck_id, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: DeckCardCreateRequest) =
        let sql = "UPDATE deck_cards SET quantity = @quantity, is_commander = @is_commander, deck_id = @deck_id, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: DeckCardUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.quantity |> Option.iter (fun v -> sets.Add("quantity = @quantity"); d.["quantity"] <- box v)
        patch.is_commander |> Option.iter (fun v -> sets.Add("is_commander = @is_commander"); d.["is_commander"] <- box v)
        patch.deck_id |> Option.iter (fun v -> sets.Add("deck_id = @deck_id"); d.["deck_id"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE deck_cards SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM deck_cards WHERE id = @id"
        conn.Execute(sql, {| id = id |})
