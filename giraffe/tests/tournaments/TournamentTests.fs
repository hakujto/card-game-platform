module cards_project.tournaments.TournamentTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TournamentApiTests() =

    [<Fact>]
    member _.``list tournament returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournaments")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create tournament returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            public_id = "00000000-0000-0000-0000-000000000001"
            name = "test"
            description = None
            status = "Draft"
            bracket_data = None
            format = "Standard"
            tournament_type = "Swiss"
            max_players = 2
            entry_fee = 1.0m
            prize_pool = 1.0m
            start_time = "2024-01-01T00:00:00"
            end_time = None
            is_online = false
            location = None
            rules_text = None
            season_id = 1L
            organizer_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/tournaments", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get tournament not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournaments/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch tournament field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/tournaments/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search tournament returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournaments?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
