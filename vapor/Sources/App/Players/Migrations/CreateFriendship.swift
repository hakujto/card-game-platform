import Fluent

struct CreateFriendship: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("friendships")
            .id()
            .field("status", .string, .required, .sql(.default("Pending")))
            .field("requester_id", .uuid, .required)
            .foreignKey("requester_id", references: "players", "id", onDelete: .cascade)
            .field("receiver_id", .uuid, .required)
            .foreignKey("receiver_id", references: "players", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("friendships").delete()
    }
}