import Vapor
import Fluent

enum PlayerCollectionCondition: String, Codable, CaseIterable {
    case mint = "Mint"
    case nearMint = "NearMint"
    case excellent = "Excellent"
    case good = "Good"
    case played = "Played"
}

enum PlayerCollectionAcquiredVia: String, Codable, CaseIterable {
    case purchase = "Purchase"
    case trade = "Trade"
    case tournamentReward = "TournamentReward"
    case pack = "Pack"
    case craft = "Craft"
}

final class PlayerCollection: Model, Content {
    static let schema = "player_collections"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "quantity")
    var quantity: Int

    @Field(key: "foil")
    var foil: Bool

    @Field(key: "condition")
    var condition: PlayerCollectionCondition

    @Field(key: "acquired_at")
    var acquiredAt: Date

    @Field(key: "acquired_via")
    var acquiredVia: PlayerCollectionAcquiredVia

    @Parent(key: "player_id")
    var player: Player

    @Parent(key: "card_id")
    var card: Card

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        quantity: Int = 1,
        foil: Bool = false,
        condition: PlayerCollectionCondition = .mint,
        acquiredAt: Date,
        acquiredVia: PlayerCollectionAcquiredVia = .purchase,
        playerID: UUID,
        cardID: UUID
    ) {
        self.id = id
        self.quantity = quantity
        self.foil = foil
        self.condition = condition
        self.acquiredAt = acquiredAt
        self.acquiredVia = acquiredVia
        self.$player.id = playerID
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var quantity: Int
        var foil: Bool
        var condition: PlayerCollectionCondition
        var acquiredAt: Date
        var acquiredVia: PlayerCollectionAcquiredVia
        var playerId: UUID?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            quantity: self.quantity,
            foil: self.foil,
            condition: self.condition,
            acquiredAt: self.acquiredAt,
            acquiredVia: self.acquiredVia,
            playerId: self.$player.id,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension PlayerCollection {
    struct CreateRequest: Content {
        var quantity: Int = 1
        var foil: Bool = false
        var condition: PlayerCollectionCondition = .mint
        var acquiredAt: Date
        var acquiredVia: PlayerCollectionAcquiredVia = .purchase
        var playerId: UUID
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var quantity: Int?
        var foil: Bool?
        var condition: PlayerCollectionCondition?
        var acquiredAt: Date?
        var acquiredVia: PlayerCollectionAcquiredVia?
        var playerId: UUID??
        var cardId: UUID??
    }
}