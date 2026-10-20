import Fluent

struct CreateCraftingIngredient: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("crafting_ingredients")
            .id()
            .field("quantity", .int, .required, .sql(.default(1)))
            .field("recipe_id", .uuid, .required)
            .foreignKey("recipe_id", references: "crafting_recipes", "id", onDelete: .cascade)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("crafting_ingredients").delete()
    }
}