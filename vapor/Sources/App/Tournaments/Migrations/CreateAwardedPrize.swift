import Fluent

struct CreateAwardedPrize: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("awarded_prizes")
            .id()
            .field("final_placement", .int, .required)
            .field("awarded_at", .datetime, .required)
            .field("claimed", .bool, .required, .sql(.default(false)))
            .field("claimed_at", .datetime)
            .field("prize_id", .uuid, .required)
            .foreignKey("prize_id", references: "tournament_prizes", "id", onDelete: .restrict)
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("awarded_prizes").delete()
    }
}