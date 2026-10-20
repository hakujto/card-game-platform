import Fluent

struct CreateTradeTransaction: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("trade_transactions")
            .id()
            .field("final_price", .double, .required)
            .field("platform_fee", .double, .required)
            .field("status", .string, .required, .sql(.default("Pending")))
            .field("completed_at", .datetime)
            .field("listing_id", .uuid, .required)
            .foreignKey("listing_id", references: "trade_listings", "id", onDelete: .restrict)
            .field("buyer_id", .uuid, .required)
            .foreignKey("buyer_id", references: "players", "id", onDelete: .restrict)
            .field("seller_id", .uuid, .required)
            .foreignKey("seller_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("trade_transactions").delete()
    }
}