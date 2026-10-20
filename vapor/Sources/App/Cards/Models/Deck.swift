import Vapor
import Fluent

enum DeckFormat: String, Codable, CaseIterable {
    case standard = "Standard"
    case extended = "Extended"
    case legacy = "Legacy"
    case vintage = "Vintage"
    case commander = "Commander"
    case draft = "Draft"
}

enum DeckArchetype: String, Codable, CaseIterable {
    case aggro = "Aggro"
    case control = "Control"
    case midrange = "Midrange"
    case combo = "Combo"
    case prison = "Prison"
    case tempo = "Tempo"
}

// Hook: after_save → recalculate_tournament_legal

final class Deck: Model, Content {
    static let schema = "decks"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "description")
    var description: String?

    @Field(key: "format")
    var format: DeckFormat

    @Field(key: "is_public")
    var isPublic: Bool

    @Field(key: "is_tournament_legal")
    var isTournamentLegal: Bool

    @OptionalField(key: "archetype")
    var archetype: DeckArchetype?

    @Field(key: "wins")
    var wins: Int

    @Field(key: "losses")
    var losses: Int

    @Field(key: "draws")
    var draws: Int

    @Parent(key: "player_id")
    var player: Player

    @Siblings(through: DeckCard.self, from: \DeckCard.$deck, to: \DeckCard.$card)
    var cards: [Card]

    @Siblings(through: DeckSideboardCard.self, from: \DeckSideboardCard.$deck, to: \DeckSideboardCard.$card)
    var sideboardCards: [Card]

    @Siblings(through: DeckTagAssignment.self, from: \DeckTagAssignment.$deck, to: \DeckTagAssignment.$tag)
    var tags: [DeckTag]

    @Children(for: \DeckCard.$deck)
    var deckCards: [DeckCard]

    @Children(for: \DeckTagAssignment.$deck)
    var tagAssignments: [DeckTagAssignment]

    @Children(for: \TournamentRegistration.$deck)
    var tournamentRegistrations: [TournamentRegistration]

    @Children(for: \Article.$featuredDeck)
    var articles: [Article]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        description: String?,
        format: DeckFormat = .standard,
        isPublic: Bool = false,
        isTournamentLegal: Bool = false,
        archetype: DeckArchetype?,
        wins: Int = 0,
        losses: Int = 0,
        draws: Int = 0,
        playerID: UUID
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.format = format
        self.isPublic = isPublic
        self.isTournamentLegal = isTournamentLegal
        self.archetype = archetype
        self.wins = wins
        self.losses = losses
        self.draws = draws
        self.$player.id = playerID
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var description: String?
        var format: DeckFormat
        var isPublic: Bool
        var isTournamentLegal: Bool
        var archetype: DeckArchetype?
        var wins: Int
        var losses: Int
        var draws: Int
        var playerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            description: self.description,
            format: self.format,
            isPublic: self.isPublic,
            isTournamentLegal: self.isTournamentLegal,
            archetype: self.archetype,
            wins: self.wins,
            losses: self.losses,
            draws: self.draws,
            playerId: self.$player.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Deck {
    struct CreateRequest: Content {
        var name: String
        var description: String?
        var format: DeckFormat = .standard
        var isPublic: Bool = false
        var isTournamentLegal: Bool = false
        var archetype: DeckArchetype?
        var wins: Int = 0
        var losses: Int = 0
        var draws: Int = 0
        var playerId: UUID
    }

    struct UpdateRequest: Content {
        var name: String?
        var description: String??
        var format: DeckFormat?
        var isPublic: Bool?
        var isTournamentLegal: Bool?
        var archetype: DeckArchetype??
        var playerId: UUID??
    }
}