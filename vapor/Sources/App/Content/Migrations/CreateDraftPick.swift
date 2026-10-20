import Fluent

struct CreateDraftPick: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("draft_picks")
            .id()
            .field("pick_number", .int, .required)
            .field("pack_number", .int, .required)
            .field("picked_at", .datetime, .required)
            .field("participant_id", .uuid, .required)
            .foreignKey("participant_id", references: "draft_participants", "id", onDelete: .cascade)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("draft_picks").delete()
    }
}