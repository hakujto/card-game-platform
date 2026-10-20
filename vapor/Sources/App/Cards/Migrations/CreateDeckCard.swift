import Fluent

struct CreateDeckCard: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("deck_cards")
            .id()
            .field("quantity", .int, .required, .sql(.default(1)))
            .field("is_commander", .bool, .required, .sql(.default(false)))
            .field("deck_id", .uuid, .required)
            .foreignKey("deck_id", references: "decks", "id", onDelete: .cascade)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("deck_cards").delete()
    }
}