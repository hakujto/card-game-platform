import Fluent

struct CreateArticle: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("articles")
            .id()
            .field("title", .string, .required)
            .field("slug", .string, .required)
            .field("body", .string, .required)
            .field("excerpt", .string)
            .field("cover_image_url", .string)
            .field("status", .string, .required, .sql(.default("Draft")))
            .field("article_type", .string, .required, .sql(.default("Guide")))
            .field("language", .string, .required, .sql(.default("EN")))
            .field("view_count", .int, .required, .sql(.default(0)))
            .field("likes_count", .int, .required, .sql(.default(0)))
            .field("total_views_alltime", .int64, .required, .sql(.default(0)))
            .field("is_featured", .bool, .required, .sql(.default(false)))
            .field("published_at", .datetime)
            .field("author_id", .uuid, .required)
            .foreignKey("author_id", references: "players", "id", onDelete: .restrict)
            .field("featured_deck_id", .uuid)
            .foreignKey("featured_deck_id", references: "decks", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "slug")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("articles").delete()
    }
}