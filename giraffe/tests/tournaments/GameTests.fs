module cards_project.tournaments.GameTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type GameApiTests() =

    [<Fact>]
    member _.``list game returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/games")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create game returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            game_number = 1
            winner_side = None
            complexity_score = None
            turns_played = None
            duration_seconds = None
            ended_by = None
            replay_url = None
            match_id = 1L
            winner_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/games", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get game not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/games/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
