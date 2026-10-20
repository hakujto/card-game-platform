import Vapor
import Fluent

final class ArticleTagAssignment: Model, Content {
    static let schema = "article_tag_assignments"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "article_id")
    var article: Article

    @Parent(key: "tag_id")
    var tag: ArticleTag

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        articleID: UUID,
        tagID: UUID
    ) {
        self.id = id
        self.$article.id = articleID
        self.$tag.id = tagID
    }

    struct DTO: Content {
        var id: UUID?
        var articleId: UUID?
        var tagId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            articleId: self.$article.id,
            tagId: self.$tag.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension ArticleTagAssignment {
    struct CreateRequest: Content {
        var articleId: UUID
        var tagId: UUID
    }

    struct UpdateRequest: Content {
        var articleId: UUID??
        var tagId: UUID??
    }
}