module cards_project.cards.DeckCardTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DeckCardApiTests() =

    [<Fact>]
    member _.``list deck_card returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_cards")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create deck_card returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 1
            is_commander = false
            deck_id = 1L
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/deck_cards", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get deck_card not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_cards/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch deck_card field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| quantity = 1 |}
        let! resp = client.PatchAsJsonAsync("/api/deck_cards/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete deck_card``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 1
            is_commander = false
            deck_id = 1L
            card_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/deck_cards", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/deck_cards/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
