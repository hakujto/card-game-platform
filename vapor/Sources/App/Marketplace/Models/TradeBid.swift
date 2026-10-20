import Vapor
import Fluent

final class TradeBid: Model, Content {
    static let schema = "trade_bids"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "amount")
    var amount: Double

    @Field(key: "placed_at")
    var placedAt: Date

    @Field(key: "is_winning")
    var isWinning: Bool

    @Parent(key: "listing_id")
    var listing: TradeListing

    @Parent(key: "bidder_id")
    var bidder: Player

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        amount: Double,
        placedAt: Date,
        isWinning: Bool = false,
        listingID: UUID,
        bidderID: UUID
    ) {
        self.id = id
        self.amount = amount
        self.placedAt = placedAt
        self.isWinning = isWinning
        self.$listing.id = listingID
        self.$bidder.id = bidderID
    }

    struct DTO: Content {
        var id: UUID?
        var amount: Double
        var placedAt: Date
        var isWinning: Bool
        var listingId: UUID?
        var bidderId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            amount: self.amount,
            placedAt: self.placedAt,
            isWinning: self.isWinning,
            listingId: self.$listing.id,
            bidderId: self.$bidder.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TradeBid {
    struct CreateRequest: Content {
        var amount: Double
        var placedAt: Date
        var isWinning: Bool = false
        var listingId: UUID
        var bidderId: UUID
    }

    struct UpdateRequest: Content {
        var amount: Double?
        var placedAt: Date?
        var isWinning: Bool?
        var listingId: UUID??
        var bidderId: UUID??
    }
}