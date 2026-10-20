module cards_project.players.PlayerCollectionTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type PlayerCollectionApiTests() =

    [<Fact>]
    member _.``list player_collection returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/player_collections")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create player_collection returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 42
            foil = false
            condition = "Mint"
            acquired_at = "2024-01-01T00:00:00"
            acquired_via = "Purchase"
            player_id = 1L
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/player_collections", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get player_collection not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/player_collections/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch player_collection field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| quantity = 42 |}
        let! resp = client.PatchAsJsonAsync("/api/player_collections/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete player_collection``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 42
            foil = false
            condition = "Mint"
            acquired_at = "2024-01-01T00:00:00"
            acquired_via = "Purchase"
            player_id = 1L
            card_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/player_collections", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/player_collections/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
