module cards_project.players.PlayerAchievementTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type PlayerAchievementApiTests() =

    [<Fact>]
    member _.``list player_achievement returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/player_achievements")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``get player_achievement not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/player_achievements/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
