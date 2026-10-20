module cards_project.tournaments.SeasonTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type SeasonApiTests() =

    [<Fact>]
    member _.``list season returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/seasons")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create season returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            start_date = "2024-01-01"
            end_date = "2024-12-31"
            format = "Standard"
            is_active = false
            reward_description = None
        |}
        let! resp = client.PostAsJsonAsync("/api/seasons", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get season not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/seasons/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch season field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/seasons/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search season returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/seasons?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
