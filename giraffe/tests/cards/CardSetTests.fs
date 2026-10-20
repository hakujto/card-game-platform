module cards_project.cards.CardSetTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CardSetApiTests() =

    [<Fact>]
    member _.``list card_set returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_sets")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create card_set returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            code = "AA"
            release_date = "2024-01-01"
            rotation_date = None
            set_type = "Core"
            total_cards = 42
            is_rotated = false
            description = None
            logo_url = None
        |}
        let! resp = client.PostAsJsonAsync("/api/card_sets", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get card_set not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_sets/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch card_set field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/card_sets/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search card_set returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_sets?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
