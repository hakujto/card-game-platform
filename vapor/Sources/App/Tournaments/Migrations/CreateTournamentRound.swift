import Fluent

struct CreateTournamentRound: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tournament_rounds")
            .id()
            .field("round_number", .int, .required)
            .field("status", .string, .required, .sql(.default("Pending")))
            .field("started_at", .datetime)
            .field("ended_at", .datetime)
            .field("time_limit_minutes", .int, .required, .sql(.default(50)))
            .field("tournament_id", .uuid, .required)
            .foreignKey("tournament_id", references: "tournaments", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tournament_rounds").delete()
    }
}