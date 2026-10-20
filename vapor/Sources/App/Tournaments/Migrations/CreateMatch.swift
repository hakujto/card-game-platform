import Fluent

struct CreateMatch: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("matchs")
            .id()
            .field("table_number", .int)
            .field("status", .string, .required, .sql(.default("Pending")))
            .field("player1_wins", .int, .required, .sql(.default(0)))
            .field("player2_wins", .int, .required, .sql(.default(0)))
            .field("started_at", .datetime)
            .field("ended_at", .datetime)
            .field("result_notes", .string)
            .field("round_id", .uuid, .required)
            .foreignKey("round_id", references: "tournament_rounds", "id", onDelete: .cascade)
            .field("player1_id", .uuid, .required)
            .foreignKey("player1_id", references: "players", "id", onDelete: .restrict)
            .field("player2_id", .uuid)
            .foreignKey("player2_id", references: "players", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("matchs").delete()
    }
}