module cards_project.marketplace.TradeListingTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TradeListingApiTests() =

    [<Fact>]
    member _.``list trade_listing returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_listings")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create trade_listing returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            public_id = "00000000-0000-0000-0000-000000000001"
            status = "Active"
            listing_type = "TradeOffer"
            asking_price = None
            auction_start_price = None
            auction_current_bid = None
            auction_end_time = None
            foil = false
            condition = "Mint"
            quantity = 1
            description = None
            expires_at = None
            seller_id = 1L
            card_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/trade_listings", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get trade_listing not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_listings/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch trade_listing field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| listing_type = "FixedPrice" |}
        let! resp = client.PatchAsJsonAsync("/api/trade_listings/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search trade_listing returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_listings?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
