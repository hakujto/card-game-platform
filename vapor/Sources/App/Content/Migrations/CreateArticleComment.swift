import Fluent

struct CreateArticleComment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("article_comments")
            .id()
            .field("body", .string, .required)
            .field("is_hidden", .bool, .required, .sql(.default(false)))
            .field("article_id", .uuid, .required)
            .foreignKey("article_id", references: "articles", "id", onDelete: .cascade)
            .field("author_id", .uuid, .required)
            .foreignKey("author_id", references: "players", "id", onDelete: .restrict)
            .field("parent_comment_id", .uuid)
            .foreignKey("parent_comment_id", references: "article_comments", "id", onDelete: .setNull)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("article_comments").delete()
    }
}