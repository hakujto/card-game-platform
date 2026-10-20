import Vapor
import Fluent

enum CouponDiscountType: String, Codable, CaseIterable {
    case percent = "Percent"
    case fixed = "Fixed"
}

final class Coupon: Model, Content {
    static let schema = "coupons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "code")
    var code: String

    @Field(key: "discount_type")
    var discountType: CouponDiscountType

    @Field(key: "discount_value")
    var discountValue: Double

    @Field(key: "min_order_value")
    var minOrderValue: Double

    @OptionalField(key: "max_uses")
    var maxUses: Int?

    @Field(key: "uses_count")
    var usesCount: Int

    @Field(key: "valid_from")
    var validFrom: Date

    @Field(key: "valid_until")
    var validUntil: Date

    @Field(key: "is_active")
    var isActive: Bool

    @Children(for: \Order.$coupon)
    var orders: [Order]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        code: String,
        discountType: CouponDiscountType = .percent,
        discountValue: Double,
        minOrderValue: Double = 0,
        maxUses: Int?,
        usesCount: Int = 0,
        validFrom: Date,
        validUntil: Date,
        isActive: Bool = true
    ) {
        self.id = id
        self.code = code
        self.discountType = discountType
        self.discountValue = discountValue
        self.minOrderValue = minOrderValue
        self.maxUses = maxUses
        self.usesCount = usesCount
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.isActive = isActive
    }

    struct DTO: Content {
        var id: UUID?
        var code: String
        var discountType: CouponDiscountType
        var discountValue: Double
        var minOrderValue: Double
        var validFrom: Date
        var validUntil: Date
        var isActive: Bool
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            code: self.code,
            discountType: self.discountType,
            discountValue: self.discountValue,
            minOrderValue: self.minOrderValue,
            validFrom: self.validFrom,
            validUntil: self.validUntil,
            isActive: self.isActive,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Coupon {
    struct CreateRequest: Content {
        var code: String
        var discountType: CouponDiscountType = .percent
        var discountValue: Double
        var minOrderValue: Double = 0
        var maxUses: Int?
        var usesCount: Int = 0
        var validFrom: Date
        var validUntil: Date
        var isActive: Bool = true
    }

    struct UpdateRequest: Content {
        var code: String?
        var discountType: CouponDiscountType?
        var discountValue: Double?
        var minOrderValue: Double?
        var maxUses: Int??
        var usesCount: Int?
        var validFrom: Date?
        var validUntil: Date?
        var isActive: Bool?
    }
}