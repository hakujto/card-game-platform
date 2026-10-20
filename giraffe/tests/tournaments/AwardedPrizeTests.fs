module cards_project.tournaments.AwardedPrizeTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type AwardedPrizeApiTests() =

    [<Fact>]
    member _.``list awarded_prize returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/awarded_prizes")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``get awarded_prize not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/awarded_prizes/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
