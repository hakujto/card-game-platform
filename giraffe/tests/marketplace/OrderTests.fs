module cards_project.marketplace.OrderTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type OrderApiTests() =

    [<Fact>]
    member _.``list order returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/orders")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create order returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            status = "Pending"
            total = 1.0m
            discount_applied = 1.0m
            currency = "AAA"
            payment_method = None
            payment_reference = None
            shipping_address = None
            tracking_number = None
            paid_at = None
            shipped_at = None
            player_id = 1L
            coupon_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/orders", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get order not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/orders/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
