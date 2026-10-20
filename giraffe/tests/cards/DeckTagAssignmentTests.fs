module cards_project.cards.DeckTagAssignmentTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type DeckTagAssignmentApiTests() =

    [<Fact>]
    member _.``list deck_tag_assignment returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_tag_assignments")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create deck_tag_assignment returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            deck_id = 1L
            tag_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/deck_tag_assignments", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get deck_tag_assignment not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/deck_tag_assignments/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``delete deck_tag_assignment``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            deck_id = 1L
            tag_id = 1L
        |}
        let! createResp = client.PostAsJsonAsync("/api/deck_tag_assignments", body)
        let! created = createResp.Content.ReadFromJsonAsync<{| id: int64 |}>()
        let! resp = client.DeleteAsync($"/api/deck_tag_assignments/{created.id}")
        Assert.Equal(HttpStatusCode.NoContent, resp.StatusCode)
    }
