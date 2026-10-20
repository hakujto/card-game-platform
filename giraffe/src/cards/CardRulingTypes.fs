module cards_project.cards.CardRulingTypes

open System.Data

[<CLIMutable>]
type CardRulingRow = {
    Id: int64
    RulingText: string
    PublishedAt: string
    Source: string
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type CardRulingDto = {
    id: int64
    ruling_text: string
    published_at: string
    source: string
    card_id: int64
    created_at: string
    updated_at: string
}

let card_rulingToDto (r: CardRulingRow) : CardRulingDto = {
    id = r.Id
    ruling_text = r.RulingText
    published_at = r.PublishedAt
    source = r.Source
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CardRulingCreateRequest = {
    ruling_text: string
    published_at: string
    source: string
    card_id: int64
}

type CardRulingUpdateRequest = {
    ruling_text: string option
    published_at: string option
    source: string option
    card_id: int64 option
}

module CardRulingDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, ruling_text, published_at, source, card_id, created_at, updated_at FROM card_rulings"
        conn.Query<CardRulingRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, ruling_text, published_at, source, card_id, created_at, updated_at FROM card_rulings WHERE id = @id"
        conn.QueryFirstOrDefault<CardRulingRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CardRulingCreateRequest) =
        let sql = "INSERT INTO card_rulings (ruling_text, published_at, source, card_id) VALUES (@ruling_text, @published_at, @source, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: CardRulingCreateRequest) =
        let sql = "UPDATE card_rulings SET ruling_text = @ruling_text, published_at = @published_at, source = @source, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: CardRulingUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.ruling_text |> Option.iter (fun v -> sets.Add("ruling_text = @ruling_text"); d.["ruling_text"] <- box v)
        patch.published_at |> Option.iter (fun v -> sets.Add("published_at = @published_at"); d.["published_at"] <- box v)
        patch.source |> Option.iter (fun v -> sets.Add("source = @source"); d.["source"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE card_rulings SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM card_rulings WHERE id = @id"
        conn.Execute(sql, {| id = id |})
