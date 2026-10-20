import Fluent

struct CreateGame: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("games")
            .id()
            .field("game_number", .int, .required)
            .field("winner_side", .string)
            .field("complexity_score", .double)
            .field("turns_played", .int)
            .field("duration_seconds", .int)
            .field("ended_by", .string)
            .field("replay_url", .string)
            .field("match_id", .uuid, .required)
            .foreignKey("match_id", references: "matchs", "id", onDelete: .cascade)
            .field("winner_id", .uuid)
            .foreignKey("winner_id", references: "players", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("games").delete()
    }
}