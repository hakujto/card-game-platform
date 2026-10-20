import Fluent

struct CreateCardPriceHistory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("card_price_historys")
            .id()
            .field("price_date", .string, .required)
            .field("avg_price", .double, .required)
            .field("min_price", .double, .required)
            .field("max_price", .double, .required)
            .field("volume", .int, .required)
            .field("foil", .bool, .required, .sql(.default(false)))
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("card_price_historys").delete()
    }
}