module cards_project.players.PlayerAchievementTypes

open System.Data

[<CLIMutable>]
type PlayerAchievementRow = {
    Id: int64
    EarnedAt: string
    Progress: int
    IsCompleted: bool
    PlayerId: int64
    AchievementId: int64
    CreatedAt: string
    UpdatedAt: string
}

type PlayerAchievementDto = {
    id: int64
    earnedAt: string
    progress: int
    is_completed: bool
    player_id: int64
    achievement_id: int64
    created_at: string
    updated_at: string
}

let player_achievementToDto (r: PlayerAchievementRow) : PlayerAchievementDto = {
    id = r.Id
    earnedAt = r.EarnedAt
    progress = r.Progress
    is_completed = r.IsCompleted
    player_id = r.PlayerId
    achievement_id = r.AchievementId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type PlayerAchievementCreateRequest = {
    earned_at: string
    progress: int
    is_completed: bool
    player_id: int64
    achievement_id: int64
}

type PlayerAchievementUpdateRequest = {
    earned_at: string option
    progress: int option
    is_completed: bool option
    player_id: int64 option
    achievement_id: int64 option
}

module PlayerAchievementDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at FROM player_achievements"
        conn.Query<PlayerAchievementRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at FROM player_achievements WHERE id = @id"
        conn.QueryFirstOrDefault<PlayerAchievementRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: PlayerAchievementCreateRequest) =
        let sql = "INSERT INTO player_achievements (earned_at, progress, is_completed, player_id, achievement_id) VALUES (@earned_at, @progress, @is_completed, @player_id, @achievement_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: PlayerAchievementCreateRequest) =
        let sql = "UPDATE player_achievements SET earned_at = @earned_at, progress = @progress, is_completed = @is_completed, player_id = @player_id, achievement_id = @achievement_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: PlayerAchievementUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.earned_at |> Option.iter (fun v -> sets.Add("earned_at = @earned_at"); d.["earned_at"] <- box v)
        patch.progress |> Option.iter (fun v -> sets.Add("progress = @progress"); d.["progress"] <- box v)
        patch.is_completed |> Option.iter (fun v -> sets.Add("is_completed = @is_completed"); d.["is_completed"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        patch.achievement_id |> Option.iter (fun v -> sets.Add("achievement_id = @achievement_id"); d.["achievement_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE player_achievements SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM player_achievements WHERE id = @id"
        conn.Execute(sql, {| id = id |})
