module cards_project.cards.DeckSideboardCardTypes

open System.Data

[<CLIMutable>]
type DeckSideboardCardRow = {
    Id: int64
    Quantity: int
    DeckId: int64
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type DeckSideboardCardDto = {
    id: int64
    quantity: int
    deck_id: int64
    card_id: int64
    created_at: string
    updated_at: string
}

let deck_sideboard_cardToDto (r: DeckSideboardCardRow) : DeckSideboardCardDto = {
    id = r.Id
    quantity = r.Quantity
    deck_id = r.DeckId
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type DeckSideboardCardCreateRequest = {
    quantity: int
    deck_id: int64
    card_id: int64
}

type DeckSideboardCardUpdateRequest = {
    quantity: int option
    deck_id: int64 option
    card_id: int64 option
}

module DeckSideboardCardDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, quantity, deck_id, card_id, created_at, updated_at FROM deck_sideboard_cards"
        conn.Query<DeckSideboardCardRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, quantity, deck_id, card_id, created_at, updated_at FROM deck_sideboard_cards WHERE id = @id"
        conn.QueryFirstOrDefault<DeckSideboardCardRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: DeckSideboardCardCreateRequest) =
        let sql = "INSERT INTO deck_sideboard_cards (quantity, deck_id, card_id) VALUES (@quantity, @deck_id, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: DeckSideboardCardCreateRequest) =
        let sql = "UPDATE deck_sideboard_cards SET quantity = @quantity, deck_id = @deck_id, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: DeckSideboardCardUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.quantity |> Option.iter (fun v -> sets.Add("quantity = @quantity"); d.["quantity"] <- box v)
        patch.deck_id |> Option.iter (fun v -> sets.Add("deck_id = @deck_id"); d.["deck_id"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE deck_sideboard_cards SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM deck_sideboard_cards WHERE id = @id"
        conn.Execute(sql, {| id = id |})
