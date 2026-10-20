module cards_project.marketplace.ProductTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type ProductApiTests() =

    [<Fact>]
    member _.``list product returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/products")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create product returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            name = "test"
            product_type = "SingleCard"
            price = 1.0m
            stock = 42
            active = false
            discount_percent = 1
            description = None
            image_url = None
            featured = false
            card_id = None
            card_set_id = None
        |}
        let! resp = client.PostAsJsonAsync("/api/products", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get product not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/products/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch product field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/products/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search product returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/products?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
