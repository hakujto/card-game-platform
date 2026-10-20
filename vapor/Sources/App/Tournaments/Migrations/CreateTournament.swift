import Fluent

struct CreateTournament: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tournaments")
            .id()
            .field("public_id", .uuid, .required)
            .field("name", .string, .required)
            .field("description", .string)
            .field("status", .string, .required, .sql(.default("Draft")))
            .field("bracket_data", .string)
            .field("format", .string, .required, .sql(.default("Standard")))
            .field("tournament_type", .string, .required, .sql(.default("Swiss")))
            .field("max_players", .int, .required)
            .field("entry_fee", .double, .required, .sql(.default(0)))
            .field("prize_pool", .double, .required, .sql(.default(0)))
            .field("start_time", .datetime, .required)
            .field("end_time", .datetime)
            .field("is_online", .bool, .required, .sql(.default(true)))
            .field("location", .string)
            .field("rules_text", .string)
            .field("season_id", .uuid, .required)
            .foreignKey("season_id", references: "seasons", "id", onDelete: .restrict)
            .field("organizer_id", .uuid, .required)
            .foreignKey("organizer_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "public_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tournaments").delete()
    }
}