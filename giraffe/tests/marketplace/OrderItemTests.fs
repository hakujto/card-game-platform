module cards_project.marketplace.OrderItemTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type OrderItemApiTests() =

    [<Fact>]
    member _.``list order_item returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/order_items")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create order_item returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 42
            price_at_purchase = 1.0m
            foil = false
            order_id = 1L
            product_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/order_items", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get order_item not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/order_items/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete order_item``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            quantity = 42
            price_at_purchase = 1.0m
            foil = false
            order_id = 1L
            product_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/order_items", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/order_items/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
