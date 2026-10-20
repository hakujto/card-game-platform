import Fluent

struct CreateTradeDispute: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("trade_disputes")
            .id()
            .field("status", .string, .required, .sql(.default("Open")))
            .field("reason", .string, .required)
            .field("description", .string, .required)
            .field("resolution", .string)
            .field("opened_at", .datetime, .required)
            .field("resolved_at", .datetime)
            .field("transaction_id", .uuid, .required)
            .foreignKey("transaction_id", references: "trade_transactions", "id", onDelete: .cascade)
            .field("opened_by_id", .uuid, .required)
            .foreignKey("opened_by_id", references: "players", "id", onDelete: .restrict)
            .field("resolved_by_id", .uuid)
            .foreignKey("resolved_by_id", references: "players", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("trade_disputes").delete()
    }
}