module cards_project.players.CraftingIngredientHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.CraftingIngredientTypes

let listCraftingIngredientHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = CraftingIngredientDb.getAll conn
        let dtos = rows |> List.map crafting_ingredientToDto
        json dtos next ctx

let getCraftingIngredientHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CraftingIngredientDb.getById conn id with
        | Some row -> json (crafting_ingredientToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCraftingIngredientHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CraftingIngredientCreateRequest>()
        let newId = CraftingIngredientDb.create conn dto
        match CraftingIngredientDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (crafting_ingredientToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let deleteCraftingIngredientHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CraftingIngredientDb.getById conn id with
        | None -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        CraftingIngredientDb.delete conn id |> ignore
        setStatusCode 204 next ctx

let crafting_ingredientsRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/crafting_ingredients" >=> choose [
            GET  >=> listCraftingIngredientHandler conn
            POST >=> createCraftingIngredientHandler conn
        ]
        routef "/api/crafting_ingredients/%d" (fun id -> choose [
            GET    >=> getCraftingIngredientHandler id conn
            DELETE >=> deleteCraftingIngredientHandler id conn
        ])
    ]