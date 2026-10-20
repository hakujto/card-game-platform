module cards_project.content.StreamTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type StreamApiTests() =

    [<Fact>]
    member _.``list stream returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/streams")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create stream returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            title = "test"
            stream_url = "https://example.com"
            status = "Scheduled"
            platform = "Twitch"
            language = "EN"
            is_official = false
            viewer_count_peak = 42
            scheduled_start = "2024-01-01T00:00:00"
            actual_start = None
            ended_at = None
            vod_url = None
            tournament_id = None
            streamer_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/streams", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get stream not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/streams/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch stream field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| title = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/streams/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search stream returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/streams?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
