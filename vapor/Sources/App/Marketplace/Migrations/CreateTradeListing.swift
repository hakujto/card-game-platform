import Fluent

struct CreateTradeListing: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("trade_listings")
            .id()
            .field("public_id", .uuid, .required)
            .field("status", .string, .required, .sql(.default("Active")))
            .field("listing_type", .string, .required, .sql(.default("FixedPrice")))
            .field("asking_price", .double)
            .field("auction_start_price", .double)
            .field("auction_current_bid", .double)
            .field("auction_end_time", .datetime)
            .field("foil", .bool, .required, .sql(.default(false)))
            .field("condition", .string, .required, .sql(.default("Mint")))
            .field("quantity", .int, .required, .sql(.default(1)))
            .field("description", .string)
            .field("expires_at", .datetime)
            .field("seller_id", .uuid, .required)
            .foreignKey("seller_id", references: "players", "id", onDelete: .restrict)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "public_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("trade_listings").delete()
    }
}