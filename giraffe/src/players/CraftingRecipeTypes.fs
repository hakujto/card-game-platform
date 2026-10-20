module cards_project.players.CraftingRecipeTypes

open System.Data

[<CLIMutable>]
type CraftingRecipeRow = {
    Id: int64
    DustCost: int
    IsAvailable: bool
    ResultCardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type CraftingRecipeDto = {
    id: int64
    dust_cost: int
    is_available: bool
    result_card_id: int64
    created_at: string
    updated_at: string
}

let crafting_recipeToDto (r: CraftingRecipeRow) : CraftingRecipeDto = {
    id = r.Id
    dust_cost = r.DustCost
    is_available = r.IsAvailable
    result_card_id = r.ResultCardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CraftingRecipeCreateRequest = {
    dust_cost: int
    is_available: bool
    result_card_id: int64
}

type CraftingRecipeUpdateRequest = {
    dust_cost: int option
    is_available: bool option
    result_card_id: int64 option
}

module CraftingRecipeDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, dust_cost, is_available, result_card_id, created_at, updated_at FROM crafting_recipes"
        conn.Query<CraftingRecipeRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, dust_cost, is_available, result_card_id, created_at, updated_at FROM crafting_recipes WHERE id = @id"
        conn.QueryFirstOrDefault<CraftingRecipeRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CraftingRecipeCreateRequest) =
        let sql = "INSERT INTO crafting_recipes (dust_cost, is_available, result_card_id) VALUES (@dust_cost, @is_available, @result_card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: CraftingRecipeCreateRequest) =
        let sql = "UPDATE crafting_recipes SET dust_cost = @dust_cost, is_available = @is_available, result_card_id = @result_card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: CraftingRecipeUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.dust_cost |> Option.iter (fun v -> sets.Add("dust_cost = @dust_cost"); d.["dust_cost"] <- box v)
        patch.is_available |> Option.iter (fun v -> sets.Add("is_available = @is_available"); d.["is_available"] <- box v)
        patch.result_card_id |> Option.iter (fun v -> sets.Add("result_card_id = @result_card_id"); d.["result_card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE crafting_recipes SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM crafting_recipes WHERE id = @id"
        conn.Execute(sql, {| id = id |})
