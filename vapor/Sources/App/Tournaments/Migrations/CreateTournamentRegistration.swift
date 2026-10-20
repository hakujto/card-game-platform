import Fluent

struct CreateTournamentRegistration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tournament_registrations")
            .id()
            .field("status", .string, .required, .sql(.default("Registered")))
            .field("seed", .int)
            .field("final_standing", .int)
            .field("points_earned", .int, .required, .sql(.default(0)))
            .field("registered_at", .datetime, .required)
            .field("tournament_id", .uuid, .required)
            .foreignKey("tournament_id", references: "tournaments", "id", onDelete: .cascade)
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .restrict)
            .field("deck_id", .uuid, .required)
            .foreignKey("deck_id", references: "decks", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tournament_registrations").delete()
    }
}