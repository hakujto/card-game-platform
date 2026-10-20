import Vapor
import Fluent

final class CraftingRecipe: Model, Content {
    static let schema = "crafting_recipes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "dust_cost")
    var dustCost: Int

    @Field(key: "is_available")
    var isAvailable: Bool

    @Parent(key: "result_card_id")
    var resultCard: Card

    @Siblings(through: CraftingIngredient.self, from: \CraftingIngredient.$recipe, to: \CraftingIngredient.$card)
    var requiredCards: [Card]

    @Children(for: \CraftingIngredient.$recipe)
    var ingredients: [CraftingIngredient]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        dustCost: Int,
        isAvailable: Bool = true,
        resultCardID: UUID
    ) {
        self.id = id
        self.dustCost = dustCost
        self.isAvailable = isAvailable
        self.$resultCard.id = resultCardID
    }

    struct DTO: Content {
        var id: UUID?
        var dustCost: Int
        var isAvailable: Bool
        var resultCardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            dustCost: self.dustCost,
            isAvailable: self.isAvailable,
            resultCardId: self.$resultCard.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension CraftingRecipe {
    struct CreateRequest: Content {
        var dustCost: Int
        var isAvailable: Bool = true
        var resultCardId: UUID
    }

    struct UpdateRequest: Content {
        var dustCost: Int?
        var isAvailable: Bool?
        var resultCardId: UUID??
    }
}