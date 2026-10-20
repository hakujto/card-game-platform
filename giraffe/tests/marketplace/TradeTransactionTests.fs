module cards_project.marketplace.TradeTransactionTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TradeTransactionApiTests() =

    [<Fact>]
    member _.``list trade_transaction returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_transactions")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``get trade_transaction not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/trade_transactions/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
