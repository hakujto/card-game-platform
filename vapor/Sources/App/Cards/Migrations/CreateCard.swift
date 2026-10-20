import Fluent

struct CreateCard: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("cards")
            .id()
            .field("public_id", .uuid, .required)
            .field("name", .string, .required)
            .field("card_type", .string, .required, .sql(.default("Creature")))
            .field("rarity", .string, .required, .sql(.default("Common")))
            .field("mana_cost", .int, .required, .sql(.default(0)))
            .field("mana_colors", .string, .required)
            .field("attack", .int)
            .field("defense", .int)
            .field("loyalty", .int)
            .field("description", .string, .required)
            .field("flavor_text", .string)
            .field("image_url", .string)
            .field("artist_name", .string)
            .field("legal_formats", .string, .required)
            .field("is_banned", .bool, .required, .sql(.default(false)))
            .field("is_restricted", .bool, .required, .sql(.default(false)))
            .field("power_level", .int, .required, .sql(.default(1)))
            .field("metadata", .string)
            .field("total_copies_in_circulation", .int64, .required, .sql(.default(0)))
            .field("set_id", .uuid, .required)
            .foreignKey("set_id", references: "card_sets", "id", onDelete: .restrict)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "public_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("cards").delete()
    }
}