module cards_project.marketplace.TradeBidTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TradeBidApiTests() =

    [<Fact>]
    member _.``list trade_bid returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_bids")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create trade_bid returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            amount = 1.0m
            placed_at = "2024-01-01T00:00:00"
            is_winning = false
            listing_id = 1L
            bidder_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/trade_bids", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get trade_bid not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_bids/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
