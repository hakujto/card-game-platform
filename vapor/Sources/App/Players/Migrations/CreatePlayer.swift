import Fluent

struct CreatePlayer: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("players")
            .id()
            .field("public_id", .uuid, .required)
            .field("display_name", .string, .required)
            .field("rank", .string, .required, .sql(.default("Bronze")))
            .field("rating", .int, .required, .sql(.default(1000)))
            .field("peak_rating", .int, .required, .sql(.default(1000)))
            .field("bio", .string)
            .field("country_code", .string)
            .field("avatar_url", .string)
            .field("preferred_format", .string)
            .field("contact_email", .string)
            .field("win_rate_cached", .double)
            .field("is_verified", .bool, .required, .sql(.default(false)))
            .field("last_active_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "public_id")
            .unique(on: "display_name")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("players").delete()
    }
}