module cards_project.marketplace.TradeDisputeTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TradeDisputeApiTests() =

    [<Fact>]
    member _.``list trade_dispute returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_disputes")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create trade_dispute returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            status = "Open"
            reason = "ItemNotReceived"
            description = "test"
            resolution = None
            opened_at = "2024-01-01T00:00:00"
            resolved_at = None
            transaction_id = 1L
            opened_by_id = 1L
            resolved_by_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/trade_disputes", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get trade_dispute not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_disputes/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
