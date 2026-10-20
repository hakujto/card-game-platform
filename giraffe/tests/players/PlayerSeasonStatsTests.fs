module cards_project.players.PlayerSeasonStatsTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type PlayerSeasonStatsApiTests() =

    [<Fact>]
    member _.``list player_season_stats returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/player_season_statses")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``get player_season_stats not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/player_season_statses/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
