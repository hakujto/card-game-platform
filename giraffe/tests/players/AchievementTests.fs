module cards_project.players.AchievementTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type AchievementApiTests() =

    [<Fact>]
    member _.``list achievement returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/achievements")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create achievement returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            description = "test"
            icon_url = None
            points = 42
            rarity = "Common"
            is_hidden = false
        |}
        let! resp = client.PostAsJsonAsync("/api/achievements", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get achievement not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/achievements/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch achievement field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/achievements/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search achievement returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/achievements?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
