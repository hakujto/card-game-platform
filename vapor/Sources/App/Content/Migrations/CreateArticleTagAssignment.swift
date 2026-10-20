import Fluent

struct CreateArticleTagAssignment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("article_tag_assignments")
            .id()
            .field("article_id", .uuid, .required)
            .foreignKey("article_id", references: "articles", "id", onDelete: .cascade)
            .field("tag_id", .uuid, .required)
            .foreignKey("tag_id", references: "article_tags", "id", onDelete: .cascade)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("article_tag_assignments").delete()
    }
}