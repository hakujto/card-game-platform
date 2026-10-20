import Fluent

struct CreateOrderItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("order_items")
            .id()
            .field("quantity", .int, .required)
            .field("price_at_purchase", .double, .required)
            .field("foil", .bool, .required, .sql(.default(false)))
            .field("order_id", .uuid, .required)
            .foreignKey("order_id", references: "orders", "id", onDelete: .cascade)
            .field("product_id", .uuid, .required)
            .foreignKey("product_id", references: "products", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("order_items").delete()
    }
}