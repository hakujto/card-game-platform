module cards_project.tournaments.TournamentPrizeTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TournamentPrizeApiTests() =

    [<Fact>]
    member _.``list tournament_prize returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_prizes")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create tournament_prize returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            placement_from = 1
            placement_to = 1
            prize_type = "Currency"
            amount = 1.0m
            description = None
            packs_count = None
            season_points = 42
            tournament_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/tournament_prizes", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get tournament_prize not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_prizes/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch tournament_prize field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| placement_from = 1 |}
        let! resp = client.PatchAsJsonAsync("/api/tournament_prizes/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete tournament_prize``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            placement_from = 1
            placement_to = 1
            prize_type = "Currency"
            amount = 1.0m
            description = None
            packs_count = None
            season_points = 42
            tournament_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/tournament_prizes", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/tournament_prizes/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
