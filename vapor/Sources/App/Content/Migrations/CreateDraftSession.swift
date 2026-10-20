import Fluent

struct CreateDraftSession: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("draft_sessions")
            .id()
            .field("status", .string, .required, .sql(.default("WaitingForPlayers")))
            .field("draft_type", .string, .required, .sql(.default("Booster")))
            .field("pack_contents", .string)
            .field("seats", .int, .required, .sql(.default(8)))
            .field("time_per_pick_seconds", .int, .required, .sql(.default(30)))
            .field("completed_at", .datetime)
            .field("card_set_id", .uuid, .required)
            .foreignKey("card_set_id", references: "card_sets", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("draft_sessions").delete()
    }
}