module cards_project.tournaments.TournamentJudgeTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TournamentJudgeApiTests() =

    [<Fact>]
    member _.``list tournament_judge returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_judges")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create tournament_judge returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            role = "HeadJudge"
            tournament_id = 1L
            player_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/tournament_judges", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get tournament_judge not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_judges/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete tournament_judge``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            role = "HeadJudge"
            tournament_id = 1L
            player_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/tournament_judges", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/tournament_judges/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
