import Fluent

struct CreateDeckTag: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("deck_tags")
            .id()
            .field("name", .string, .required)
            .field("slug", .string)
            .field("color", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("deck_tags").delete()
    }
}