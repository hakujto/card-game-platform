module cards_project.tournaments.TournamentJudgeTypes

open System.Data

type TournamentJudgeRole =
    | HeadJudge
    | Judge
    | ScorekeeperJudge

    static member ToString = function
        | HeadJudge -> "HeadJudge"
        | Judge -> "Judge"
        | ScorekeeperJudge -> "ScorekeeperJudge"

    static member FromString s =
        match s with
        | "HeadJudge" -> HeadJudge
        | "Judge" -> Judge
        | "ScorekeeperJudge" -> ScorekeeperJudge
        | _ -> failwithf "Unknown TournamentJudgeRole: %s" s

[<CLIMutable>]
type TournamentJudgeRow = {
    Id: int64
    Role: string
    TournamentId: int64
    PlayerId: int64
    CreatedAt: string
    UpdatedAt: string
}

type TournamentJudgeDto = {
    id: int64
    role: string
    tournament_id: int64
    player_id: int64
    created_at: string
    updated_at: string
}

let tournament_judgeToDto (r: TournamentJudgeRow) : TournamentJudgeDto = {
    id = r.Id
    role = r.Role
    tournament_id = r.TournamentId
    player_id = r.PlayerId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type TournamentJudgeCreateRequest = {
    role: string
    tournament_id: int64
    player_id: int64
}

type TournamentJudgeUpdateRequest = {
    role: string option
    tournament_id: int64 option
    player_id: int64 option
}

module TournamentJudgeDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, role, tournament_id, player_id, created_at, updated_at FROM tournament_judges"
        conn.Query<TournamentJudgeRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, role, tournament_id, player_id, created_at, updated_at FROM tournament_judges WHERE id = @id"
        conn.QueryFirstOrDefault<TournamentJudgeRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: TournamentJudgeCreateRequest) =
        let sql = "INSERT INTO tournament_judges (role, tournament_id, player_id) VALUES (@role, @tournament_id, @player_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: TournamentJudgeCreateRequest) =
        let sql = "UPDATE tournament_judges SET role = @role, tournament_id = @tournament_id, player_id = @player_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: TournamentJudgeUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.role |> Option.iter (fun v -> sets.Add("role = @role"); d.["role"] <- box v)
        patch.tournament_id |> Option.iter (fun v -> sets.Add("tournament_id = @tournament_id"); d.["tournament_id"] <- box v)
        patch.player_id |> Option.iter (fun v -> sets.Add("player_id = @player_id"); d.["player_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE tournament_judges SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM tournament_judges WHERE id = @id"
        conn.Execute(sql, {| id = id |})
