import Fluent

struct CreatePlayerSeasonStats: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("player_season_statss")
            .id()
            .field("wins", .int, .required, .sql(.default(0)))
            .field("losses", .int, .required, .sql(.default(0)))
            .field("draws", .int, .required, .sql(.default(0)))
            .field("tournament_wins", .int, .required, .sql(.default(0)))
            .field("highest_rank", .string)
            .field("season_points", .int, .required, .sql(.default(0)))
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .cascade)
            .field("season_id", .uuid, .required)
            .foreignKey("season_id", references: "seasons", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("player_season_statss").delete()
    }
}