import Vapor
import Fluent

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case paid = "Paid"
    case processing = "Processing"
    case shipped = "Shipped"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case refunded = "Refunded"
}

enum OrderPaymentMethod: String, Codable, CaseIterable {
    case card = "Card"
    case payPal = "PayPal"
    case crypto = "Crypto"
    case platformCredits = "PlatformCredits"
}

// Hook: before_create → assign_currency_default
// Hook: after_update → notify_status_change

// Audit: track changes (track, actor)

final class Order: Model, Content {
    static let schema = "orders"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: OrderStatus

    @Field(key: "total")
    var total: Double

    @Field(key: "discount_applied")
    var discountApplied: Double

    @Field(key: "currency")
    var currency: String

    @OptionalField(key: "payment_method")
    var paymentMethod: OrderPaymentMethod?

    @OptionalField(key: "payment_reference")
    var paymentReference: String?

    @OptionalField(key: "shipping_address")
    var shippingAddress: String?

    @OptionalField(key: "tracking_number")
    var trackingNumber: String?

    @OptionalField(key: "paid_at")
    var paidAt: Date?

    @OptionalField(key: "shipped_at")
    var shippedAt: Date?

    @Parent(key: "player_id")
    var player: Player

    @OptionalParent(key: "coupon_id")
    var coupon: Coupon?

    @Children(for: \OrderItem.$order)
    var items: [OrderItem]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        status: OrderStatus = .pending,
        total: Double = 0,
        discountApplied: Double = 0,
        currency: String = "USD",
        paymentMethod: OrderPaymentMethod?,
        paymentReference: String?,
        shippingAddress: String?,
        trackingNumber: String?,
        paidAt: Date?,
        shippedAt: Date?,
        playerID: UUID,
        couponID: UUID? = nil
    ) {
        self.id = id
        self.status = status
        self.total = total
        self.discountApplied = discountApplied
        self.currency = currency
        self.paymentMethod = paymentMethod
        self.paymentReference = paymentReference
        self.shippingAddress = shippingAddress
        self.trackingNumber = trackingNumber
        self.paidAt = paidAt
        self.shippedAt = shippedAt
        self.$player.id = playerID
        self.$coupon.id = couponID
    }

    struct DTO: Content {
        var id: UUID?
        var status: OrderStatus
        var total: Double
        var discountApplied: Double
        var currency: String
        var paymentMethod: OrderPaymentMethod?
        var shippingAddress: String?
        var trackingNumber: String?
        var paidAt: Date?
        var shippedAt: Date?
        var playerId: UUID?
        var couponId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            status: self.status,
            total: self.total,
            discountApplied: self.discountApplied,
            currency: self.currency,
            paymentMethod: self.paymentMethod,
            shippingAddress: self.shippingAddress,
            trackingNumber: self.trackingNumber,
            paidAt: self.paidAt,
            shippedAt: self.shippedAt,
            playerId: self.$player.id,
            couponId: self.$coupon.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Order {
    struct CreateRequest: Content {
        var status: OrderStatus = .pending
        var total: Double = 0
        var discountApplied: Double = 0
        var currency: String = "USD"
        var paymentMethod: OrderPaymentMethod?
        var paymentReference: String?
        var shippingAddress: String?
        var trackingNumber: String?
        var paidAt: Date?
        var shippedAt: Date?
        var playerId: UUID
        var couponId: UUID?
    }

    struct UpdateRequest: Content {
        var total: Double?
        var discountApplied: Double?
        var currency: String?
        var paymentMethod: OrderPaymentMethod??
        var paymentReference: String??
        var shippingAddress: String??
        var trackingNumber: String??
        var shippedAt: Date??
        var playerId: UUID??
        var couponId: UUID??
    }
}