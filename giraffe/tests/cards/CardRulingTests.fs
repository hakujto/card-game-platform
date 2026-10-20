module cards_project.cards.CardRulingTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CardRulingApiTests() =

    [<Fact>]
    member _.``list card_ruling returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_rulings")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create card_ruling returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            ruling_text = "test"
            published_at = "2024-01-01"
            source = "test"
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/card_rulings", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get card_ruling not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_rulings/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete card_ruling``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            ruling_text = "test"
            published_at = "2024-01-01"
            source = "test"
            card_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/card_rulings", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/card_rulings/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
