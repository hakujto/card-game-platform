import Vapor
import Fluent

final class CraftingIngredient: Model, Content {
    static let schema = "crafting_ingredients"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "quantity")
    var quantity: Int

    @Parent(key: "recipe_id")
    var recipe: CraftingRecipe

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
        recipeID: UUID,
        cardID: UUID
    ) {
        self.id = id
        self.quantity = quantity
        self.$recipe.id = recipeID
        self.$card.id = cardID
    }

    struct DTO: Content {
        var id: UUID?
        var quantity: Int
        var recipeId: UUID?
        var cardId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            quantity: self.quantity,
            recipeId: self.$recipe.id,
            cardId: self.$card.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension CraftingIngredient {
    struct CreateRequest: Content {
        var quantity: Int = 1
        var recipeId: UUID
        var cardId: UUID
    }

    struct UpdateRequest: Content {
        var quantity: Int?
        var recipeId: UUID??
        var cardId: UUID??
    }
}