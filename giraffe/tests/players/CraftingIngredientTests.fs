module cards_project.players.CraftingIngredientTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CraftingIngredientApiTests() =

    [<Fact>]
    member _.``list crafting_ingredient returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/crafting_ingredients")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create crafting_ingredient returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 42
            recipe_id = 1L
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/crafting_ingredients", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get crafting_ingredient not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/crafting_ingredients/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete crafting_ingredient``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 42
            recipe_id = 1L
            card_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/crafting_ingredients", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/crafting_ingredients/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
