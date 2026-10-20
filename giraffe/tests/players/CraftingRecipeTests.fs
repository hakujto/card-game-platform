module cards_project.players.CraftingRecipeTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CraftingRecipeApiTests() =

    [<Fact>]
    member _.``list crafting_recipe returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/crafting_recipes")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create crafting_recipe returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            dust_cost = 42
            is_available = false
            result_card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/crafting_recipes", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get crafting_recipe not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/crafting_recipes/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch crafting_recipe field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| dust_cost = 42 |}
        let! resp = client.PatchAsJsonAsync("/api/crafting_recipes/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
