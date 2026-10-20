import Fluent

struct CreateOrder: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("orders")
            .id()
            .field("status", .string, .required, .sql(.default("Pending")))
            .field("total", .double, .required, .sql(.default(0)))
            .field("discount_applied", .double, .required, .sql(.default(0)))
            .field("currency", .string, .required, .sql(.default("USD")))
            .field("payment_method", .string)
            .field("payment_reference", .string)
            .field("shipping_address", .string)
            .field("tracking_number", .string)
            .field("paid_at", .datetime)
            .field("shipped_at", .datetime)
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .restrict)
            .field("coupon_id", .uuid)
            .foreignKey("coupon_id", references: "coupons", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("orders").delete()
    }
}