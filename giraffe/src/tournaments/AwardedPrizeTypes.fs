module cards_project.tournaments.AwardedPrizeTypes

open System.Data

[<CLIMutable>]
type AwardedPrizeRow = {
    Id: int64
    FinalPlacement: int
    AwardedAt: string
    Claimed: bool
    ClaimedAt: string option
    PrizeId: int64
    PlayerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type AwardedPrizeDto = {
    id: int64
    final_placement: int
    awardedAt: string
    claimed: bool
    claimedAt: string option
    prize_id: int64
    player_id: int64
    created_at: string
    updated_at: string
}

let awarded_prizeToDto (r: AwardedPrizeRow) : AwardedPrizeDto = {
    id = r.Id
    final_placement = r.FinalPlacement
    awardedAt = r.AwardedAt
    claimed = r.Claimed
    claimedAt = r.ClaimedAt
    prize_id = r.PrizeId
    player_id = r.PlayerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type AwardedPrizeCreateRequest = {
    final_placement: int
    awarded_at: string
    claimed: bool
    claimed_at: string option
    prize_id: int64
    player_id: int64
}

type AwardedPrizeUpdateRequest = {
    claimed: bool option
    claimed_at: string option option
    prize_id: int64 option
    player_id: int64 option
}

module AwardedPrizeDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at FROM awarded_prizes"
        conn.Query<AwardedPrizeRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at FROM awarded_prizes WHERE id = @id"
        conn.QueryFirstOrDefault<AwardedPrizeRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: AwardedPrizeCreateRequest) =
        let sql = "INSERT INTO awarded_prizes (final_placement, awarded_at, claimed, claimed_at, prize_id, player_id) VALUES (@final_placement, @awarded_at, @claimed, @claimed_at, @prize_id, @player_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["final_placement"] <- box dto.final_placement
        p.["awarded_at"] <- box dto.awarded_at
        p.["claimed"] <- box dto.claimed
        p.["claimed_at"] <- match dto.claimed_at with Some v -> box v | None -> null
        p.["prize_id"] <- box dto.prize_id
        p.["player_id"] <- box dto.player_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: AwardedPrizeCreateRequest) =
        let sql = "UPDATE awarded_prizes SET final_placement = @final_placement, awarded_at = @awarded_at, claimed = @claimed, claimed_at = @claimed_at, prize_id = @prize_id, player_id = @player_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["final_placement"] <- box dto.final_placement
        p.["awarded_at"] <- box dto.awarded_at
        p.["claimed"] <- box dto.claimed
        p.["claimed_at"] <- match dto.claimed_at with Some v -> box v | None -> null
        p.["prize_id"] <- box dto.prize_id
        p.["player_id"] <- box dto.player_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: AwardedPrizeUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.claimed |> Option.iter (fun v -> sets.Add("claimed = @claimed"); d.["claimed"] <- box v)
        patch.claimed_at |> Option.iter (fun v -> sets.Add("claimed_at = @claimed_at"); d.["claimed_at"] <- match v with Some s -> box s | None -> null)
        patch.prize_id |> Option.iter (fun v -> sets.Add("prize_id = @prize_id"); d.["prize_id"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE awarded_prizes SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM awarded_prizes WHERE id = @id"
        conn.Execute(sql, {| id = id |})
