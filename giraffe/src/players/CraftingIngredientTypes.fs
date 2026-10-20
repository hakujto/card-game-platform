module cards_project.players.CraftingIngredientTypes

open System.Data

[<CLIMutable>]
type CraftingIngredientRow = {
    Id: int64
    Quantity: int
    RecipeId: int64
    CardId: int64
    CreatedAt: string
    UpdatedAt: string
}

type CraftingIngredientDto = {
    id: int64
    quantity: int
    recipe_id: int64
    card_id: int64
    created_at: string
    updated_at: string
}

let crafting_ingredientToDto (r: CraftingIngredientRow) : CraftingIngredientDto = {
    id = r.Id
    quantity = r.Quantity
    recipe_id = r.RecipeId
    card_id = r.CardId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CraftingIngredientCreateRequest = {
    quantity: int
    recipe_id: int64
    card_id: int64
}

type CraftingIngredientUpdateRequest = {
    quantity: int option
    recipe_id: int64 option
    card_id: int64 option
}

module CraftingIngredientDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, quantity, recipe_id, card_id, created_at, updated_at FROM crafting_ingredients"
        conn.Query<CraftingIngredientRow>(sql) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, quantity, recipe_id, card_id, created_at, updated_at FROM crafting_ingredients WHERE id = @id"
        conn.QueryFirstOrDefault<CraftingIngredientRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CraftingIngredientCreateRequest) =
        let sql = "INSERT INTO crafting_ingredients (quantity, recipe_id, card_id) VALUES (@quantity, @recipe_id, @card_id); SELECT last_insert_rowid()"
        conn.ExecuteScalar<int64>(sql, dto)

    let update (conn: IDbConnection) (id: int64) (dto: CraftingIngredientCreateRequest) =
        let sql = "UPDATE crafting_ingredients SET quantity = @quantity, recipe_id = @recipe_id, card_id = @card_id, updated_at = datetime('now') WHERE id = @id"
        conn.Execute(sql, {| dto with id = id |})

    let patch (conn: IDbConnection) (id: int64) (patch: CraftingIngredientUpdateRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.quantity |> Option.iter (fun v -> sets.Add("quantity = @quantity"); d.["quantity"] <- box v)
        patch.recipe_id |> Option.iter (fun v -> sets.Add("recipe_id = @recipe_id"); d.["recipe_id"] <- box v)
        patch.card_id |> Option.iter (fun v -> sets.Add("card_id = @card_id"); d.["card_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE crafting_ingredients SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM crafting_ingredients WHERE id = @id"
        conn.Execute(sql, {| id = id |})
