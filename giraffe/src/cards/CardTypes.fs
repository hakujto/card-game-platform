module cards_project.cards.CardTypes

open System.Data

type CardCardType =
    | Creature
    | Spell
    | Land
    | Artifact
    | Enchantment
    | Planeswalker

    static member ToString = function
        | Creature -> "Creature"
        | Spell -> "Spell"
        | Land -> "Land"
        | Artifact -> "Artifact"
        | Enchantment -> "Enchantment"
        | Planeswalker -> "Planeswalker"

    static member FromString s =
        match s with
        | "Creature" -> Creature
        | "Spell" -> Spell
        | "Land" -> Land
        | "Artifact" -> Artifact
        | "Enchantment" -> Enchantment
        | "Planeswalker" -> Planeswalker
        | _ -> failwithf "Unknown CardCardType: %s" s

type CardRarity =
    | Common
    | Uncommon
    | Rare
    | MythicRare
    | Legendary

    static member ToString = function
        | Common -> "Common"
        | Uncommon -> "Uncommon"
        | Rare -> "Rare"
        | MythicRare -> "MythicRare"
        | Legendary -> "Legendary"

    static member FromString s =
        match s with
        | "Common" -> Common
        | "Uncommon" -> Uncommon
        | "Rare" -> Rare
        | "MythicRare" -> MythicRare
        | "Legendary" -> Legendary
        | _ -> failwithf "Unknown CardRarity: %s" s

type CardManaColors =
    | White
    | Blue
    | Black
    | Red
    | Green
    | Colorless

    static member ToString = function
        | White -> "White"
        | Blue -> "Blue"
        | Black -> "Black"
        | Red -> "Red"
        | Green -> "Green"
        | Colorless -> "Colorless"

    static member FromString s =
        match s with
        | "White" -> White
        | "Blue" -> Blue
        | "Black" -> Black
        | "Red" -> Red
        | "Green" -> Green
        | "Colorless" -> Colorless
        | _ -> failwithf "Unknown CardManaColors: %s" s

type CardLegalFormats =
    | Standard
    | Extended
    | Legacy
    | Vintage
    | Commander
    | Draft

    static member ToString = function
        | Standard -> "Standard"
        | Extended -> "Extended"
        | Legacy -> "Legacy"
        | Vintage -> "Vintage"
        | Commander -> "Commander"
        | Draft -> "Draft"

    static member FromString s =
        match s with
        | "Standard" -> Standard
        | "Extended" -> Extended
        | "Legacy" -> Legacy
        | "Vintage" -> Vintage
        | "Commander" -> Commander
        | "Draft" -> Draft
        | _ -> failwithf "Unknown CardLegalFormats: %s" s

[<CLIMutable>]
type CardRow = {
    Id: int64
    PublicId: string
    Name: string
    CardType: string
    Rarity: string
    ManaCost: int
    ManaColors: string
    Attack: int64 option
    Defense: int64 option
    Loyalty: int64 option
    Description: string
    FlavorText: string option
    ImageUrl: string option
    ArtistName: string option
    LegalFormats: string
    IsBanned: bool
    IsRestricted: bool
    PowerLevel: int
    Metadata: string option
    TotalCopiesInCirculation: int64
    SetId: int64
    CreatedAt: string
    UpdatedAt: string
}

type CardDto = {
    id: int64
    public_id: string
    name: string
    card_type: string
    rarity: string
    mana_cost: int
    mana_colors: string
    attack: int option
    defense: int option
    loyalty: int option
    description: string
    flavor_text: string option
    image_url: string option
    artist_name: string option
    legal_formats: string
    is_banned: bool
    is_restricted: bool
    power_level: int
    metadata: string option
    total_copies_in_circulation: int64
    set_id: int64
    created_at: string
    updated_at: string
}

let cardToDto (r: CardRow) : CardDto = {
    id = r.Id
    public_id = r.PublicId
    name = r.Name
    card_type = r.CardType
    rarity = r.Rarity
    mana_cost = r.ManaCost
    mana_colors = r.ManaColors
    attack = r.Attack |> Option.map int
    defense = r.Defense |> Option.map int
    loyalty = r.Loyalty |> Option.map int
    description = r.Description
    flavor_text = r.FlavorText
    image_url = r.ImageUrl
    artist_name = r.ArtistName
    legal_formats = r.LegalFormats
    is_banned = r.IsBanned
    is_restricted = r.IsRestricted
    power_level = r.PowerLevel
    metadata = r.Metadata
    total_copies_in_circulation = r.TotalCopiesInCirculation
    set_id = r.SetId
    created_at = r.CreatedAt
    updated_at = r.UpdatedAt
}

type CardCreateRequest = {
    public_id: string
    name: string
    card_type: string
    rarity: string
    mana_cost: int
    mana_colors: string
    attack: int option
    defense: int option
    loyalty: int option
    description: string
    flavor_text: string option
    image_url: string option
    artist_name: string option
    legal_formats: string
    is_banned: bool
    is_restricted: bool
    power_level: int
    metadata: string option
    total_copies_in_circulation: int64
    set_id: int64
}

type CardUpdateRequest = {
    public_id: string option
    name: string option
    card_type: string option
    rarity: string option
    mana_cost: int option
    mana_colors: string option
    attack: int option option
    defense: int option option
    loyalty: int option option
    description: string option
    image_url: string option option
    legal_formats: string option
    power_level: int option
    metadata: string option option
    total_copies_in_circulation: int64 option
    set_id: int64 option
}

type CardPatchRequest = {
    public_id: string option
    name: string option
    card_type: string option
    rarity: string option
    mana_cost: int option
    mana_colors: string option
    attack: int option option
    defense: int option option
    loyalty: int option option
    description: string option
    flavor_text: string option option
    image_url: string option option
    artist_name: string option option
    legal_formats: string option
    power_level: int option
    metadata: string option option
    total_copies_in_circulation: int64 option
    set_id: int64 option
}

// hook: before_save
let validate_legality (entity: CardRow) =
    // TODO: implement validate_legality hook
    entity

// hook: before_delete
let validate_not_in_use (entity: CardRow) =
    // TODO: implement validate_not_in_use hook
    entity

module CardDb =
    open Dapper

    let getAll (conn: IDbConnection) =
        let sql = "SELECT id, public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id, created_at, updated_at FROM cards"
        conn.Query<CardRow>(sql) |> Seq.toList

    let search (conn: IDbConnection) (q: string) =
        let sql = "SELECT id, public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id, created_at, updated_at FROM cards WHERE name LIKE @q OR artist_name LIKE @q"
        conn.Query<CardRow>(sql, {| q = "%" + q + "%" |}) |> Seq.toList

    let getById (conn: IDbConnection) (id: int64) =
        let sql = "SELECT id, public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id, created_at, updated_at FROM cards WHERE id = @id"
        conn.QueryFirstOrDefault<CardRow>(sql, {| id = id |})
        |> Option.ofObj

    let create (conn: IDbConnection) (dto: CardCreateRequest) =
        let sql = "INSERT INTO cards (public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id) VALUES (@public_id, @name, @card_type, @rarity, @mana_cost, @mana_colors, @attack, @defense, @loyalty, @description, @flavor_text, @image_url, @artist_name, @legal_formats, @is_banned, @is_restricted, @power_level, @metadata, @total_copies_in_circulation, @set_id); SELECT last_insert_rowid()"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["public_id"] <- box dto.public_id
        p.["name"] <- box dto.name
        p.["card_type"] <- box dto.card_type
        p.["rarity"] <- box dto.rarity
        p.["mana_cost"] <- box dto.mana_cost
        p.["mana_colors"] <- box dto.mana_colors
        p.["attack"] <- match dto.attack with Some v -> box v | None -> null
        p.["defense"] <- match dto.defense with Some v -> box v | None -> null
        p.["loyalty"] <- match dto.loyalty with Some v -> box v | None -> null
        p.["description"] <- box dto.description
        p.["flavor_text"] <- match dto.flavor_text with Some v -> box v | None -> null
        p.["image_url"] <- match dto.image_url with Some v -> box v | None -> null
        p.["artist_name"] <- match dto.artist_name with Some v -> box v | None -> null
        p.["legal_formats"] <- box dto.legal_formats
        p.["is_banned"] <- box dto.is_banned
        p.["is_restricted"] <- box dto.is_restricted
        p.["power_level"] <- box dto.power_level
        p.["metadata"] <- match dto.metadata with Some v -> box v | None -> null
        p.["total_copies_in_circulation"] <- box dto.total_copies_in_circulation
        p.["set_id"] <- box dto.set_id
        conn.ExecuteScalar<int64>(sql, p)

    let update (conn: IDbConnection) (id: int64) (dto: CardCreateRequest) =
        let sql = "UPDATE cards SET public_id = @public_id, name = @name, card_type = @card_type, rarity = @rarity, mana_cost = @mana_cost, mana_colors = @mana_colors, attack = @attack, defense = @defense, loyalty = @loyalty, description = @description, flavor_text = @flavor_text, image_url = @image_url, artist_name = @artist_name, legal_formats = @legal_formats, is_banned = @is_banned, is_restricted = @is_restricted, power_level = @power_level, metadata = @metadata, total_copies_in_circulation = @total_copies_in_circulation, set_id = @set_id, updated_at = datetime('now') WHERE id = @id"
        let mutable p = System.Collections.Generic.Dictionary<string, obj>()
        p.["id"] <- box id
        p.["public_id"] <- box dto.public_id
        p.["name"] <- box dto.name
        p.["card_type"] <- box dto.card_type
        p.["rarity"] <- box dto.rarity
        p.["mana_cost"] <- box dto.mana_cost
        p.["mana_colors"] <- box dto.mana_colors
        p.["attack"] <- match dto.attack with Some v -> box v | None -> null
        p.["defense"] <- match dto.defense with Some v -> box v | None -> null
        p.["loyalty"] <- match dto.loyalty with Some v -> box v | None -> null
        p.["description"] <- box dto.description
        p.["flavor_text"] <- match dto.flavor_text with Some v -> box v | None -> null
        p.["image_url"] <- match dto.image_url with Some v -> box v | None -> null
        p.["artist_name"] <- match dto.artist_name with Some v -> box v | None -> null
        p.["legal_formats"] <- box dto.legal_formats
        p.["is_banned"] <- box dto.is_banned
        p.["is_restricted"] <- box dto.is_restricted
        p.["power_level"] <- box dto.power_level
        p.["metadata"] <- match dto.metadata with Some v -> box v | None -> null
        p.["total_copies_in_circulation"] <- box dto.total_copies_in_circulation
        p.["set_id"] <- box dto.set_id
        conn.Execute(sql, p)

    let patch (conn: IDbConnection) (id: int64) (patch: CardPatchRequest) =
        // Build SET clause from non-None patch fields
        let sets = System.Collections.Generic.List<string>()
        let p = dict []
        let mutable d = System.Collections.Generic.Dictionary<string, obj>()
        d.["id"] <- box id
        patch.public_id |> Option.iter (fun v -> sets.Add("public_id = @public_id"); d.["public_id"] <- box v)
        patch.name |> Option.iter (fun v -> sets.Add("name = @name"); d.["name"] <- box v)
        patch.card_type |> Option.iter (fun v -> sets.Add("card_type = @card_type"); d.["card_type"] <- box v)
        patch.rarity |> Option.iter (fun v -> sets.Add("rarity = @rarity"); d.["rarity"] <- box v)
        patch.mana_cost |> Option.iter (fun v -> sets.Add("mana_cost = @mana_cost"); d.["mana_cost"] <- box v)
        patch.mana_colors |> Option.iter (fun v -> sets.Add("mana_colors = @mana_colors"); d.["mana_colors"] <- box v)
        patch.attack |> Option.iter (fun v -> sets.Add("attack = @attack"); d.["attack"] <- match v with Some s -> box s | None -> null)
        patch.defense |> Option.iter (fun v -> sets.Add("defense = @defense"); d.["defense"] <- match v with Some s -> box s | None -> null)
        patch.loyalty |> Option.iter (fun v -> sets.Add("loyalty = @loyalty"); d.["loyalty"] <- match v with Some s -> box s | None -> null)
        patch.description |> Option.iter (fun v -> sets.Add("description = @description"); d.["description"] <- box v)
        patch.flavor_text |> Option.iter (fun v -> sets.Add("flavor_text = @flavor_text"); d.["flavor_text"] <- match v with Some s -> box s | None -> null)
        patch.image_url |> Option.iter (fun v -> sets.Add("image_url = @image_url"); d.["image_url"] <- match v with Some s -> box s | None -> null)
        patch.artist_name |> Option.iter (fun v -> sets.Add("artist_name = @artist_name"); d.["artist_name"] <- match v with Some s -> box s | None -> null)
        patch.legal_formats |> Option.iter (fun v -> sets.Add("legal_formats = @legal_formats"); d.["legal_formats"] <- box v)
        patch.power_level |> Option.iter (fun v -> sets.Add("power_level = @power_level"); d.["power_level"] <- box v)
        patch.metadata |> Option.iter (fun v -> sets.Add("metadata = @metadata"); d.["metadata"] <- match v with Some s -> box s | None -> null)
        patch.total_copies_in_circulation |> Option.iter (fun v -> sets.Add("total_copies_in_circulation = @total_copies_in_circulation"); d.["total_copies_in_circulation"] <- box v)
        patch.set_id |> Option.iter (fun v -> sets.Add("set_id = @set_id"); d.["set_id"] <- box v)
        if sets.Count = 0 then 0
        else
            let sql = sprintf "UPDATE cards SET %s, updated_at = datetime('now') WHERE id = @id" (String.concat ", " sets)
            conn.Execute(sql, d)

    let delete (conn: IDbConnection) (id: int64) =
        let sql = "DELETE FROM cards WHERE id = @id"
        conn.Execute(sql, {| id = id |})
