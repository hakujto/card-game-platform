import Fluent

struct CreatePlayerAchievement: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("player_achievements")
            .id()
            .field("earned_at", .datetime, .required)
            .field("progress", .int, .required, .sql(.default(0)))
            .field("is_completed", .bool, .required, .sql(.default(false)))
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .cascade)
            .field("achievement_id", .uuid, .required)
            .foreignKey("achievement_id", references: "achievements", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("player_achievements").delete()
    }
}