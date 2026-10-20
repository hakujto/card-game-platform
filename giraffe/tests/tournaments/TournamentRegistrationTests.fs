module cards_project.tournaments.TournamentRegistrationTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type TournamentRegistrationApiTests() =

    [<Fact>]
    member _.``list tournament_registration returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_registrations")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create tournament_registration returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            status = "Registered"
            seed = None
            final_standing = None
            points_earned = 42
            registered_at = "2024-01-01T00:00:00"
            tournament_id = 1L
            player_id = 1L
            deck_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/tournament_registrations", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get tournament_registration not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/tournament_registrations/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }
