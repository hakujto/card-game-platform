module cards_project.cards.CardTests

open System.Net
open System.Net.Http.Json
open Xunit
open cards_project.TestHelpers

[<Collection("Sequential")>]
type CardApiTests() =

    [<Fact>]
    member _.``list card returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/cards")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``create card returns 201``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let body = {|
            public_id = "00000000-0000-0000-0000-000000000001"
            name = "test"
            card_type = "Spell"
            rarity = "Common"
            mana_cost = 1
            mana_colors = "White"
            attack = None
            defense = None
            loyalty = None
            description = "test"
            flavor_text = None
            image_url = None
            artist_name = None
            legal_formats = "Standard"
            is_banned = false
            is_restricted = false
            power_level = 1
            metadata = None
            total_copies_in_circulation = 42L
            set_id = 1L
        |}
        let! resp = client.PostAsJsonAsync("/api/cards", body)
        Assert.Equal(HttpStatusCode.Created, resp.StatusCode)
    }

    [<Fact>]
    member _.``get card not found returns 404``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/cards/99999")
        Assert.Equal(HttpStatusCode.NotFound, resp.StatusCode)
    }

    [<Fact>]
    member _.``patch card field``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let patch = {| name = "test" |}
        let! resp = client.PatchAsJsonAsync("/api/cards/1", patch)
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }

    [<Fact>]
    member _.``search card returns 200``() = task {
        use factory = new ApiFactory()
        let client = factory.CreateClient()
        let! resp = client.GetAsync("/api/cards?q=test")
        Assert.Equal(HttpStatusCode.OK, resp.StatusCode)
    }
