module cards_project.marketplace.CouponTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CouponApiTests() =

    [<Fact>]
    member _.``list coupon returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/coupons")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create coupon returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            code = "test"
            discount_type = "Percent"
            discount_value = 1.0m
            min_order_value = 1.0m
            max_uses = None
            uses_count = 42
            valid_from = "2024-01-01T00:00:00"
            valid_until = "2024-12-31T23:59:59"
            is_active = false
        |}
        let! resp = client.PostAsJsonAsync("/api/coupons", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get coupon not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/coupons/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch coupon field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| discount_type = "Percent" |}
        let! resp = client.PatchAsJsonAsync("/api/coupons/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search coupon returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/coupons?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
