import Fluent

struct CreateTradeBid: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("trade_bids")
            .id()
            .field("amount", .double, .required)
            .field("placed_at", .datetime, .required)
            .field("is_winning", .bool, .required, .sql(.default(false)))
            .field("listing_id", .uuid, .required)
            .foreignKey("listing_id", references: "trade_listings", "id", onDelete: .cascade)
            .field("bidder_id", .uuid, .required)
            .foreignKey("bidder_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("trade_bids").delete()
    }
}