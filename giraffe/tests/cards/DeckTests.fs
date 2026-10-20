module cards_project.cards.DeckTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DeckApiTests() =

    [<Fact>]
    member _.``list deck returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/decks")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create deck returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            description = None
            format = "Standard"
            is_public = false
            is_tournament_legal = false
            archetype = None
            wins = 42
            losses = 42
            draws = 42
            player_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/decks", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get deck not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/decks/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch deck field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/decks/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete deck``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            description = None
            format = "Standard"
            is_public = false
            is_tournament_legal = false
            archetype = None
            wins = 42
            losses = 42
            draws = 42
            player_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/decks", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/decks/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }

    [<Fact>]
    member _.``search deck returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/decks?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
