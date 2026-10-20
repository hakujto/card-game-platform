import Vapor
import Fluent

final class CardPriceHistory: Model, Content {
    static let schema = "card_price_historys"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "price_date")
    var priceDate: String

    @Field(key: "avg_price")
    var avgPrice: Double

    @Field(key: "min_price")
    var minPrice: Double

    @Field(key: "max_price")
    var maxPrice: Double

    @Field(key: "volume")
    var volume: Int

    @Field(key: "foil")
    var foil: Bool

    @Parent(key: "card_id")
    var card: Card

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        priceDate: String,
        avgPrice: Double,
        minPrice: Double,
        maxPrice: Double,
        volume: Int,
        foil: Bool = false,
        cardID: UUID
    ) {
        self.id = id
        self.priceDate = priceDate
        self.avgPrice = avgPrice
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.volume = volume
        self.foil = foil
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var priceDate: String
        var avgPrice: Double
        var minPrice: Double
        var maxPrice: Double
        var volume: Int
        var foil: Bool
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            priceDate: self.priceDate,
            avgPrice: self.avgPrice,
            minPrice: self.minPrice,
            maxPrice: self.maxPrice,
            volume: self.volume,
            foil: self.foil,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension CardPriceHistory {
    struct CreateRequest: Content {
        var priceDate: String
        var avgPrice: Double
        var minPrice: Double
        var maxPrice: Double
        var volume: Int
        var foil: Bool = false
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var priceDate: String?
        var avgPrice: Double?
        var minPrice: Double?
        var maxPrice: Double?
        var volume: Int?
        var foil: Bool?
        var cardId: UUID??
    }
}