import Fluent

struct CreateAchievement: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("achievements")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("icon_url", .string)
            .field("points", .int, .required, .sql(.default(10)))
            .field("rarity", .string, .required, .sql(.default("Common")))
            .field("is_hidden", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("achievements").delete()
    }
}