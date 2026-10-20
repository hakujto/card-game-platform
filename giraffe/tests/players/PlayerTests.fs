module cards_project.players.PlayerTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type PlayerApiTests() =

    [<Fact>]
    member _.``list player returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/players")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create player returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            public_id = "00000000-0000-0000-0000-000000000001"
            display_name = "test"
            rank = "Bronze"
            rating = 1
            peak_rating = 42
            bio = None
            country_code = None
            avatar_url = None
            preferred_format = None
            contact_email = None
            win_rate_cached = None
            is_verified = false
            last_active_at = None
            user_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/players", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get player not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/players/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch player field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| rank = "Bronze" |}
        let! resp = client.PatchAsJsonAsync("/api/players/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search player returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/players?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
