module cards_project.players.FriendshipTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type FriendshipApiTests() =

    [<Fact>]
    member _.``list friendship returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/friendships")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create friendship returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            status = "Pending"
            requester_id = 1L
            receiver_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/friendships", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get friendship not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/friendships/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete friendship``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            status = "Pending"
            requester_id = 1L
            receiver_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/friendships", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/friendships/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
