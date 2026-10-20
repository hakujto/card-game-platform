import Fluent

struct CreateStream: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("streams")
            .id()
            .field("title", .string, .required)
            .field("stream_url", .string, .required)
            .field("status", .string, .required, .sql(.default("Scheduled")))
            .field("platform", .string, .required, .sql(.default("Twitch")))
            .field("language", .string, .required, .sql(.default("EN")))
            .field("is_official", .bool, .required, .sql(.default(false)))
            .field("viewer_count_peak", .int, .required, .sql(.default(0)))
            .field("scheduled_start", .datetime, .required)
            .field("actual_start", .datetime)
            .field("ended_at", .datetime)
            .field("vod_url", .string)
            .field("tournament_id", .uuid)
            .foreignKey("tournament_id", references: "tournaments", "id", onDelete: .setNull)
            .field("streamer_id", .uuid, .required)
            .foreignKey("streamer_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("streams").delete()
    }
}