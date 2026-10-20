import Fluent

struct CreateDeckTagAssignment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("deck_tag_assignments")
            .id()
            .field("deck_id", .uuid, .required)
            .foreignKey("deck_id", references: "decks", "id", onDelete: .cascade)
            .field("tag_id", .uuid, .required)
            .foreignKey("tag_id", references: "deck_tags", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("deck_tag_assignments").delete()
    }
}