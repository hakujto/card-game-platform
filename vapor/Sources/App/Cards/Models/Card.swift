import Vapor
import Fluent

enum CardCardType: String, Codable, CaseIterable {
    case creature = "Creature"
    case spell = "Spell"
    case land = "Land"
    case artifact = "Artifact"
    case enchantment = "Enchantment"
    case planeswalker = "Planeswalker"
}

enum CardRarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case mythicRare = "MythicRare"
    case legendary = "Legendary"
}

enum CardManaColors: String, Codable, CaseIterable {
    case white = "White"
    case blue = "Blue"
    case black = "Black"
    case red = "Red"
    case green = "Green"
    case colorless = "Colorless"
}

enum CardLegalFormats: String, Codable, CaseIterable {
    case standard = "Standard"
    case extended = "Extended"
    case legacy = "Legacy"
    case vintage = "Vintage"
    case commander = "Commander"
    case draft = "Draft"
}

// Hook: before_save → validate_legality
// Hook: before_delete → validate_not_in_use

// Audit: track changes (track, actor)

final class Card: Model, Content {
    static let schema = "cards"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "public_id")
    var publicId: UUID

    @Field(key: "name")
    var name: String

    @Field(key: "card_type")
    var cardType: CardCardType

    @Field(key: "rarity")
    var rarity: CardRarity

    @Field(key: "mana_cost")
    var manaCost: Int

    @Field(key: "mana_colors")
    var manaColors: CardManaColors

    @OptionalField(key: "attack")
    var attack: Int?

    @OptionalField(key: "defense")
    var defense: Int?

    @OptionalField(key: "loyalty")
    var loyalty: Int?

    @Field(key: "description")
    var description: String

    @OptionalField(key: "flavor_text")
    var flavorText: String?

    @OptionalField(key: "image_url")
    var imageUrl: String?

    @OptionalField(key: "artist_name")
    var artistName: String?

    @Field(key: "legal_formats")
    var legalFormats: CardLegalFormats

    @Field(key: "is_banned")
    var isBanned: Bool

    @Field(key: "is_restricted")
    var isRestricted: Bool

    @Field(key: "power_level")
    var powerLevel: Int

    @OptionalField(key: "metadata")
    var metadata: String?

    @Field(key: "total_copies_in_circulation")
    var totalCopiesInCirculation: Int

    @Parent(key: "set_id")
    var set: CardSet

    @Children(for: \CardRuling.$card)
    var rulings: [CardRuling]

    @Children(for: \CardAbility.$card)
    var abilities: [CardAbility]

    @Children(for: \DeckCard.$card)
    var deckCards: [DeckCard]

    @Children(for: \DeckSideboardCard.$card)
    var sideboardDecks: [DeckSideboardCard]

    @Children(for: \PlayerCollection.$card)
    var playerCollections: [PlayerCollection]

    @Children(for: \CraftingRecipe.$resultCard)
    var craftingRecipes: [CraftingRecipe]

    @Children(for: \CraftingIngredient.$card)
    var usedInRecipes: [CraftingIngredient]

    @OptionalChild(for: \Product.$card)
    var shopProduct: Product?

    @Children(for: \TradeListing.$card)
    var tradeListings: [TradeListing]

    @Children(for: \CardPriceHistory.$card)
    var priceHistory: [CardPriceHistory]

    @Children(for: \DraftPick.$card)
    var draftPicks: [DraftPick]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        publicId: UUID,
        name: String,
        cardType: CardCardType = .creature,
        rarity: CardRarity = .common,
        manaCost: Int = 0,
        manaColors: CardManaColors,
        attack: Int?,
        defense: Int?,
        loyalty: Int?,
        description: String,
        flavorText: String?,
        imageUrl: String?,
        artistName: String?,
        legalFormats: CardLegalFormats,
        isBanned: Bool = false,
        isRestricted: Bool = false,
        powerLevel: Int = 1,
        metadata: String?,
        totalCopiesInCirculation: Int = 0,
        setID: UUID
    ) {
        self.id = id
        self.publicId = publicId
        self.name = name
        self.cardType = cardType
        self.rarity = rarity
        self.manaCost = manaCost
        self.manaColors = manaColors
        self.attack = attack
        self.defense = defense
        self.loyalty = loyalty
        self.description = description
        self.flavorText = flavorText
        self.imageUrl = imageUrl
        self.artistName = artistName
        self.legalFormats = legalFormats
        self.isBanned = isBanned
        self.isRestricted = isRestricted
        self.powerLevel = powerLevel
        self.metadata = metadata
        self.totalCopiesInCirculation = totalCopiesInCirculation
        self.$set.id = setID
    }

    struct DTO: Content {
        var id: UUID?
        var publicId: UUID
        var name: String
        var cardType: CardCardType
        var rarity: CardRarity
        var manaCost: Int
        var manaColors: CardManaColors
        var attack: Int?
        var defense: Int?
        var loyalty: Int?
        var description: String
        var flavorText: String?
        var imageUrl: String?
        var artistName: String?
        var legalFormats: CardLegalFormats
        var isBanned: Bool
        var isRestricted: Bool
        var powerLevel: Int
        var metadata: String?
        var totalCopiesInCirculation: Int
        var setId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            publicId: self.publicId,
            name: self.name,
            cardType: self.cardType,
            rarity: self.rarity,
            manaCost: self.manaCost,
            manaColors: self.manaColors,
            attack: self.attack,
            defense: self.defense,
            loyalty: self.loyalty,
            description: self.description,
            flavorText: self.flavorText,
            imageUrl: self.imageUrl,
            artistName: self.artistName,
            legalFormats: self.legalFormats,
            isBanned: self.isBanned,
            isRestricted: self.isRestricted,
            powerLevel: self.powerLevel,
            metadata: self.metadata,
            totalCopiesInCirculation: self.totalCopiesInCirculation,
            setId: self.$set.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Card {
    struct CreateRequest: Content {
        var publicId: UUID
        var name: String
        var cardType: CardCardType = .creature
        var rarity: CardRarity = .common
        var manaCost: Int = 0
        var manaColors: CardManaColors
        var attack: Int?
        var defense: Int?
        var loyalty: Int?
        var description: String
        var flavorText: String?
        var imageUrl: String?
        var artistName: String?
        var legalFormats: CardLegalFormats
        var isBanned: Bool = false
        var isRestricted: Bool = false
        var powerLevel: Int = 1
        var metadata: String?
        var totalCopiesInCirculation: Int = 0
        var setId: UUID
    }

    struct UpdateRequest: Content {
        var publicId: UUID?
        var name: String?
        var cardType: CardCardType?
        var rarity: CardRarity?
        var manaCost: Int?
        var manaColors: CardManaColors?
        var attack: Int??
        var defense: Int??
        var loyalty: Int??
        var description: String?
        var flavorText: String??
        var imageUrl: String??
        var artistName: String??
        var legalFormats: CardLegalFormats?
        var powerLevel: Int?
        var metadata: String??
        var totalCopiesInCirculation: Int?
        var setId: UUID??
    }
}