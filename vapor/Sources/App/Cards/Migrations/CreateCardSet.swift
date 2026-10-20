import Fluent

struct CreateCardSet: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("card_sets")
            .id()
            .field("name", .string, .required)
            .field("code", .string, .required)
            .field("release_date", .string, .required)
            .field("rotation_date", .string)
            .field("set_type", .string, .required, .sql(.default("Expansion")))
            .field("total_cards", .int, .required)
            .field("is_rotated", .bool, .required, .sql(.default(false)))
            .field("description", .string)
            .field("logo_url", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "code")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("card_sets").delete()
    }
}