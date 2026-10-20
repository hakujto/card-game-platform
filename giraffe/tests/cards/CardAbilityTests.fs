module cards_project.cards.CardAbilityTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CardAbilityApiTests() =

    [<Fact>]
    member _.``list card_ability returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_abilities")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create card_ability returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            ability_type = "Activated"
            keyword = None
            ability_text = "test"
            timing = None
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/card_abilities", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get card_ability not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_abilities/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch card_ability field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| ability_type = "Keyword" |}
        let! resp = client.PatchAsJsonAsync("/api/card_abilities/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete card_ability``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            ability_type = "Activated"
            keyword = None
            ability_text = "test"
            timing = None
            card_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/card_abilities", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/card_abilities/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }

    [<Fact>]
    member _.``search card_ability returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_abilities?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
