import Fluent

struct CreateProduct: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("products")
            .id()
            .field("name", .string, .required)
            .field("product_type", .string, .required, .sql(.default("SingleCard")))
            .field("price", .double, .required)
            .field("stock", .int, .required, .sql(.default(0)))
            .field("active", .bool, .required, .sql(.default(true)))
            .field("discount_percent", .int, .required, .sql(.default(0)))
            .field("description", .string)
            .field("image_url", .string)
            .field("featured", .bool, .required, .sql(.default(false)))
            .field("card_id", .uuid)
            .foreignKey("card_id", references: "cards", "id", onDelete: .setNull)
            .field("card_set_id", .uuid)
            .foreignKey("card_set_id", references: "card_sets", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("products").delete()
    }
}