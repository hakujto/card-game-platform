import Fluent

struct CreateDeck: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("decks")
            .id()
            .field("name", .string, .required)
            .field("description", .string)
            .field("format", .string, .required, .sql(.default("Standard")))
            .field("is_public", .bool, .required, .sql(.default(false)))
            .field("is_tournament_legal", .bool, .required, .sql(.default(false)))
            .field("archetype", .string)
            .field("wins", .int, .required, .sql(.default(0)))
            .field("losses", .int, .required, .sql(.default(0)))
            .field("draws", .int, .required, .sql(.default(0)))
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("decks").delete()
    }
}