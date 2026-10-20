import Fluent

struct CreateCardRuling: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("card_rulings")
            .id()
            .field("ruling_text", .string, .required)
            .field("published_at", .string, .required)
            .field("source", .string, .required)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("card_rulings").delete()
    }
}