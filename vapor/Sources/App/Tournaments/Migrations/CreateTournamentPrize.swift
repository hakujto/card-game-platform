import Fluent

struct CreateTournamentPrize: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tournament_prizes")
            .id()
            .field("placement_from", .int, .required)
            .field("placement_to", .int, .required)
            .field("prize_type", .string, .required)
            .field("amount", .double, .required, .sql(.default(0)))
            .field("description", .string)
            .field("packs_count", .int)
            .field("season_points", .int, .required, .sql(.default(0)))
            .field("tournament_id", .uuid, .required)
            .foreignKey("tournament_id", references: "tournaments", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tournament_prizes").delete()
    }
}