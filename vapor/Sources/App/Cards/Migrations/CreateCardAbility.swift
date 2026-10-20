import Fluent

struct CreateCardAbility: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("card_abilitys")
            .id()
            .field("ability_type", .string, .required, .sql(.default("Keyword")))
            .field("keyword", .string)
            .field("ability_text", .string, .required)
            .field("timing", .string)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("card_abilitys").delete()
    }
}