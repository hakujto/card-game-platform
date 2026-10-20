module cards_project.cards.DeckSideboardCardTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DeckSideboardCardApiTests() =

    [<Fact>]
    member _.``list deck_sideboard_card returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_sideboard_cards")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create deck_sideboard_card returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 1
            deck_id = 1L
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/deck_sideboard_cards", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get deck_sideboard_card not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_sideboard_cards/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch deck_sideboard_card field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| quantity = 42 |}
        let! resp = client.PatchAsJsonAsync("/api/deck_sideboard_cards/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete deck_sideboard_card``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 1
            deck_id = 1L
            card_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/deck_sideboard_cards", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/deck_sideboard_cards/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
