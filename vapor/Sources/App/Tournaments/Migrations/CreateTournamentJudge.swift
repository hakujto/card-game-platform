import Fluent

struct CreateTournamentJudge: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tournament_judges")
            .id()
            .field("role", .string, .required, .sql(.default("Judge")))
            .field("tournament_id", .uuid, .required)
            .foreignKey("tournament_id", references: "tournaments", "id", onDelete: .cascade)
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tournament_judges").delete()
    }
}