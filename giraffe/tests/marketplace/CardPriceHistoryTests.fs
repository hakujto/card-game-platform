module cards_project.marketplace.CardPriceHistoryTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CardPriceHistoryApiTests() =

    [<Fact>]
    member _.``list card_price_history returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_price_histories")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``get card_price_history not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/card_price_histories/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
