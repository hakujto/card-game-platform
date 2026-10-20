import Fluent

struct CreateCraftingRecipe: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("crafting_recipes")
            .id()
            .field("dust_cost", .int, .required)
            .field("is_available", .bool, .required, .sql(.default(true)))
            .field("result_card_id", .uuid, .required)
            .foreignKey("result_card_id", references: "cards", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("crafting_recipes").delete()
    }
}