import Vapor
import Fluent

final class OrderItem: Model, Content {
    static let schema = "order_items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "quantity")
    var quantity: Int

    @Field(key: "price_at_purchase")
    var priceAtPurchase: Double

    @Field(key: "foil")
    var foil: Bool

    @Parent(key: "order_id")
    var order: Order

    @Parent(key: "product_id")
    var product: Product

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        quantity: Int,
        priceAtPurchase: Double,
        foil: Bool = false,
        orderID: UUID,
        productID: UUID
    ) {
        self.id = id
        self.quantity = quantity
        self.priceAtPurchase = priceAtPurchase
        self.foil = foil
        self.$order.id = orderID
        self.$product.id = productID
    }

    struct DTO: Content {
        var id: UUID?
        var quantity: Int
        var priceAtPurchase: Double
        var foil: Bool
        var orderId: UUID?
        var productId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            quantity: self.quantity,
            priceAtPurchase: self.priceAtPurchase,
            foil: self.foil,
            orderId: self.$order.id,
            productId: self.$product.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension OrderItem {
    struct CreateRequest: Content {
        var quantity: Int
        var priceAtPurchase: Double
        var foil: Bool = false
        var orderId: UUID
        var productId: UUID
    }

    struct UpdateRequest: Content {
        var quantity: Int?
        var priceAtPurchase: Double?
        var foil: Bool?
        var orderId: UUID??
        var productId: UUID??
    }
}