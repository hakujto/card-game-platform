import Fluent

struct CreateDraftParticipant: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("draft_participants")
            .id()
            .field("seat_number", .int, .required)
            .field("joined_at", .datetime, .required)
            .field("session_id", .uuid, .required)
            .foreignKey("session_id", references: "draft_sessions", "id", onDelete: .cascade)
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("draft_participants").delete()
    }
}