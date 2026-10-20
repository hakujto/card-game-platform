import Vapor
import Fluent

enum TradeListingStatus: String, Codable, CaseIterable {
    case active = "Active"
    case sold = "Sold"
    case expired = "Expired"
    case cancelled = "Cancelled"
    case pending = "Pending"
}

enum TradeListingListingType: String, Codable, CaseIterable {
    case fixedPrice = "FixedPrice"
    case auction = "Auction"
    case tradeOffer = "TradeOffer"
}

enum TradeListingCondition: String, Codable, CaseIterable {
    case mint = "Mint"
    case nearMint = "NearMint"
    case excellent = "Excellent"
    case good = "Good"
    case played = "Played"
}

final class TradeListing: Model, Content {
    static let schema = "trade_listings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "public_id")
    var publicId: UUID

    @Field(key: "status")
    var status: TradeListingStatus

    @Field(key: "listing_type")
    var listingType: TradeListingListingType

    @OptionalField(key: "asking_price")
    var askingPrice: Double?

    @OptionalField(key: "auction_start_price")
    var auctionStartPrice: Double?

    @OptionalField(key: "auction_current_bid")
    var auctionCurrentBid: Double?

    @OptionalField(key: "auction_end_time")
    var auctionEndTime: Date?

    @Field(key: "foil")
    var foil: Bool

    @Field(key: "condition")
    var condition: TradeListingCondition

    @Field(key: "quantity")
    var quantity: Int

    @OptionalField(key: "description")
    var description: String?

    @OptionalField(key: "expires_at")
    var expiresAt: Date?

    @Parent(key: "seller_id")
    var seller: Player

    @Parent(key: "card_id")
    var card: Card

    @Children(for: \TradeBid.$listing)
    var bids: [TradeBid]

    @OptionalChild(for: \TradeTransaction.$listing)
    var transaction: TradeTransaction?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        publicId: UUID,
        status: TradeListingStatus = .active,
        listingType: TradeListingListingType = .fixedPrice,
        askingPrice: Double?,
        auctionStartPrice: Double?,
        auctionCurrentBid: Double?,
        auctionEndTime: Date?,
        foil: Bool = false,
        condition: TradeListingCondition = .mint,
        quantity: Int = 1,
        description: String?,
        expiresAt: Date?,
        sellerID: UUID,
        cardID: UUID
    ) {
        self.id = id
        self.publicId = publicId
        self.status = status
        self.listingType = listingType
        self.askingPrice = askingPrice
        self.auctionStartPrice = auctionStartPrice
        self.auctionCurrentBid = auctionCurrentBid
        self.auctionEndTime = auctionEndTime
        self.foil = foil
        self.condition = condition
        self.quantity = quantity
        self.description = description
        self.expiresAt = expiresAt
        self.$seller.id = sellerID
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var publicId: UUID
        var status: TradeListingStatus
        var listingType: TradeListingListingType
        var askingPrice: Double?
        var auctionStartPrice: Double?
        var auctionCurrentBid: Double?
        var auctionEndTime: Date?
        var foil: Bool
        var condition: TradeListingCondition
        var quantity: Int
        var description: String?
        var expiresAt: Date?
        var sellerId: UUID?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            publicId: self.publicId,
            status: self.status,
            listingType: self.listingType,
            askingPrice: self.askingPrice,
            auctionStartPrice: self.auctionStartPrice,
            auctionCurrentBid: self.auctionCurrentBid,
            auctionEndTime: self.auctionEndTime,
            foil: self.foil,
            condition: self.condition,
            quantity: self.quantity,
            description: self.description,
            expiresAt: self.expiresAt,
            sellerId: self.$seller.id,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TradeListing {
    struct CreateRequest: Content {
        var publicId: UUID
        var status: TradeListingStatus = .active
        var listingType: TradeListingListingType = .fixedPrice
        var askingPrice: Double?
        var auctionStartPrice: Double?
        var auctionCurrentBid: Double?
        var auctionEndTime: Date?
        var foil: Bool = false
        var condition: TradeListingCondition = .mint
        var quantity: Int = 1
        var description: String?
        var expiresAt: Date?
        var sellerId: UUID
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var publicId: UUID?
        var listingType: TradeListingListingType?
        var askingPrice: Double??
        var auctionStartPrice: Double??
        var auctionCurrentBid: Double??
        var auctionEndTime: Date??
        var foil: Bool?
        var condition: TradeListingCondition?
        var quantity: Int?
        var description: String??
        var expiresAt: Date??
        var sellerId: UUID??
        var cardId: UUID??
    }
}