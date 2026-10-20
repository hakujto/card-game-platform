import Fluent

struct CreatePlayerCollection: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("player_collections")
            .id()
            .field("quantity", .int, .required, .sql(.default(1)))
            .field("foil", .bool, .required, .sql(.default(false)))
            .field("condition", .string, .required, .sql(.default("Mint")))
            .field("acquired_at", .datetime, .required)
            .field("acquired_via", .string, .required, .sql(.default("Purchase")))
            .field("player_id", .uuid, .required)
            .foreignKey("player_id", references: "players", "id", onDelete: .cascade)
            .field("card_id", .uuid, .required)
            .foreignKey("card_id", references: "cards", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("player_collections").delete()
    }
}