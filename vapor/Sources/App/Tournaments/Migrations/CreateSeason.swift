import Fluent

struct CreateSeason: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("seasons")
            .id()
            .field("name", .string, .required)
            .field("start_date", .string, .required)
            .field("end_date", .string, .required)
            .field("format", .string, .required, .sql(.default("Standard")))
            .field("is_active", .bool, .required, .sql(.default(false)))
            .field("reward_description", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("seasons").delete()
    }
}