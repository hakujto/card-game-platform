import Fluent

struct CreateArticleTag: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("article_tags")
            .id()
            .field("name", .string, .required)
            .field("slug", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "slug")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("article_tags").delete()
    }
}