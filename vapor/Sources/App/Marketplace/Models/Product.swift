import Vapor
import Fluent

enum ProductProductType: String, Codable, CaseIterable {
    case singleCard = "SingleCard"
    case boosterPack = "BoosterPack"
    case bundle = "Bundle"
    case preconstructedDeck = "PreconstructedDeck"
    case accessory = "Accessory"
}

final class Product: Model, Content {
    static let schema = "products"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "product_type")
    var productType: ProductProductType

    @Field(key: "price")
    var price: Double

    @Field(key: "stock")
    var stock: Int

    @Field(key: "active")
    var active: Bool

    @Field(key: "discount_percent")
    var discountPercent: Int

    @OptionalField(key: "description")
    var description: String?

    @OptionalField(key: "image_url")
    var imageUrl: String?

    @Field(key: "featured")
    var featured: Bool

    @OptionalParent(key: "card_id")
    var card: Card?

    @OptionalParent(key: "card_set_id")
    var cardSet: CardSet?

    @Children(for: \OrderItem.$product)
    var orderItems: [OrderItem]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        productType: ProductProductType = .singleCard,
        price: Double,
        stock: Int = 0,
        active: Bool = true,
        discountPercent: Int = 0,
        description: String?,
        imageUrl: String?,
        featured: Bool = false,
        cardID: UUID? = nil,
        cardSetID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.productType = productType
        self.price = price
        self.stock = stock
        self.active = active
        self.discountPercent = discountPercent
        self.description = description
        self.imageUrl = imageUrl
        self.featured = featured
        self.$card.id = cardID
        self.$cardSet.id = cardSetID
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var productType: ProductProductType
        var price: Double
        var stock: Int
        var active: Bool
        var discountPercent: Int
        var description: String?
        var imageUrl: String?
        var featured: Bool
        var cardId: UUID?
        var cardSetId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            productType: self.productType,
            price: self.price,
            stock: self.stock,
            active: self.active,
            discountPercent: self.discountPercent,
            description: self.description,
            imageUrl: self.imageUrl,
            featured: self.featured,
            cardId: self.$card.id,
            cardSetId: self.$cardSet.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Product {
    struct CreateRequest: Content {
        var name: String
        var productType: ProductProductType = .singleCard
        var price: Double
        var stock: Int = 0
        var active: Bool = true
        var discountPercent: Int = 0
        var description: String?
        var imageUrl: String?
        var featured: Bool = false
        var cardId: UUID?
        var cardSetId: UUID?
    }

    struct UpdateRequest: Content {
        var name: String?
        var productType: ProductProductType?
        var price: Double?
        var stock: Int?
        var active: Bool?
        var discountPercent: Int?
        var description: String??
        var imageUrl: String??
        var featured: Bool?
        var cardId: UUID??
        var cardSetId: UUID??
    }
}