module cards_project.players.CraftingRecipeHandler

open System.Data
open Giraffe
open Microsoft.AspNetCore.Http
open cards_project.players.CraftingRecipeTypes

let validateCraftingRecipe (r: CraftingRecipeCreateRequest) =
    let errors = System.Collections.Generic.List<string>()
    if not ((r.dust_cost > 0)) then errors.Add("Crafting recipe must have a dust cost greater than zero")
    if errors.Count > 0 then Error (List.ofSeq errors) else Ok ()

let listCraftingRecipeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        let rows = CraftingRecipeDb.getAll conn
        let dtos = rows |> List.map crafting_recipeToDto
        json dtos next ctx

let getCraftingRecipeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx ->
        match CraftingRecipeDb.getById conn id with
        | Some row -> json (crafting_recipeToDto row) next ctx
        | None     -> (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx

let createCraftingRecipeHandler (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        let! dto = ctx.BindJsonAsync<CraftingRecipeCreateRequest>()
        match validateCraftingRecipe dto with
        | Error errs ->
            return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        let newId = CraftingRecipeDb.create conn dto
        match CraftingRecipeDb.getById conn newId with
        | Some row -> return! (setStatusCode 201 >=> json (crafting_recipeToDto row)) next ctx
        | None     -> return! (setStatusCode 500 >=> json {| error = "Created but not found" |}) next ctx
    }

let updateCraftingRecipeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CraftingRecipeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! dto = ctx.BindJsonAsync<CraftingRecipeCreateRequest>()
        match validateCraftingRecipe dto with
        | Error errs -> return! (setStatusCode 422 >=> json {| errors = errs |}) next ctx
        | Ok () ->
        CraftingRecipeDb.update conn id dto |> ignore
        match CraftingRecipeDb.getById conn id with
        | Some row -> return! json (crafting_recipeToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let patchCraftingRecipeHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CraftingRecipeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some _ ->
        let! patch = ctx.BindJsonAsync<CraftingRecipeUpdateRequest>()
        CraftingRecipeDb.patch conn id patch |> ignore
        match CraftingRecipeDb.getById conn id with
        | Some row -> return! json (crafting_recipeToDto row) next ctx
        | None     -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
    }

let behaviorCanCraftHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CraftingRecipeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement can_craft behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorExecuteCraftHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CraftingRecipeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement execute_craft behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorDisableHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CraftingRecipeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement disable behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let behaviorEnableHandler (id: int64) (conn: IDbConnection) : HttpHandler =
    fun next ctx -> task {
        match CraftingRecipeDb.getById conn id with
        | None -> return! (setStatusCode 404 >=> json {| error = "Not found" |}) next ctx
        | Some row ->
            // TODO: implement enable behavior
            return! json {| result = "ok"; id = id |} next ctx
    }

let crafting_recipesRoutes (conn: IDbConnection) : HttpHandler =
    choose [
        route "/api/crafting_recipes" >=> choose [
            GET  >=> listCraftingRecipeHandler conn
            POST >=> createCraftingRecipeHandler conn
        ]
        routef "/api/crafting_recipes/%d" (fun id -> choose [
            GET    >=> getCraftingRecipeHandler id conn
            PUT    >=> updateCraftingRecipeHandler id conn
            PATCH  >=> patchCraftingRecipeHandler id conn
        ])
        routef "/api/crafting_recipes/%d/can-craft" (fun id -> behaviorCanCraftHandler id conn)
        routef "/api/crafting_recipes/%d/craft" (fun id -> behaviorExecuteCraftHandler id conn)
        routef "/api/crafting_recipes/%d/disable" (fun id -> behaviorDisableHandler id conn)
        routef "/api/crafting_recipes/%d/enable" (fun id -> behaviorEnableHandler id conn)
    ]