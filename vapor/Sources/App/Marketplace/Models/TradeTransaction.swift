import Vapor
import Fluent

enum TradeTransactionStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case completed = "Completed"
    case disputed = "Disputed"
    case refunded = "Refunded"
}

// Audit: track changes (track, actor)

final class TradeTransaction: Model, Content {
    static let schema = "trade_transactions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "final_price")
    var finalPrice: Double

    @Field(key: "platform_fee")
    var platformFee: Double

    @Field(key: "status")
    var status: TradeTransactionStatus

    @OptionalField(key: "completed_at")
    var completedAt: Date?

    @Parent(key: "listing_id")
    var listing: TradeListing

    @Parent(key: "buyer_id")
    var buyer: Player

    @Parent(key: "seller_id")
    var seller: Player

    @OptionalChild(for: \TradeDispute.$transaction)
    var dispute: TradeDispute?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        finalPrice: Double,
        platformFee: Double,
        status: TradeTransactionStatus = .pending,
        completedAt: Date?,
        listingID: UUID,
        buyerID: UUID,
        sellerID: UUID
    ) {
        self.id = id
        self.finalPrice = finalPrice
        self.platformFee = platformFee
        self.status = status
        self.completedAt = completedAt
        self.$listing.id = listingID
        self.$buyer.id = buyerID
        self.$seller.id = sellerID
    }

    struct DTO: Content {
        var id: UUID?
        var finalPrice: Double
        var platformFee: Double
        var status: TradeTransactionStatus
        var completedAt: Date?
        var listingId: UUID?
        var buyerId: UUID?
        var sellerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            finalPrice: self.finalPrice,
            platformFee: self.platformFee,
            status: self.status,
            completedAt: self.completedAt,
            listingId: self.$listing.id,
            buyerId: self.$buyer.id,
            sellerId: self.$seller.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TradeTransaction {
    struct CreateRequest: Content {
        var finalPrice: Double
        var platformFee: Double
        var status: TradeTransactionStatus = .pending
        var completedAt: Date?
        var listingId: UUID
        var buyerId: UUID
        var sellerId: UUID
    }

    struct UpdateRequest: Content {
        var finalPrice: Double?
        var platformFee: Double?
        var status: TradeTransactionStatus?
        var completedAt: Date??
        var listingId: UUID??
        var buyerId: UUID??
        var sellerId: UUID??
    }
}