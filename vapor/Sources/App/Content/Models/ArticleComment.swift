import Vapor
import Fluent

final class ArticleComment: Model, Content {
    static let schema = "article_comments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "body")
    var body: String

    @Field(key: "is_hidden")
    var isHidden: Bool

    @Parent(key: "article_id")
    var article: Article

    @Parent(key: "author_id")
    var author: Player

    @OptionalParent(key: "parent_comment_id")
    var parentComment: ArticleComment?

    @Children(for: \ArticleComment.$parentComment)
    var replies: [ArticleComment]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        body: String,
        isHidden: Bool = false,
        articleID: UUID,
        authorID: UUID,
        parentCommentID: UUID? = nil
    ) {
        self.id = id
        self.body = body
        self.isHidden = isHidden
        self.$article.id = articleID
        self.$author.id = authorID
        self.$parentComment.id = parentCommentID
    }

    struct DTO: Content {
        var id: UUID?
        var body: String
        var isHidden: Bool
        var articleId: UUID?
        var authorId: UUID?
        var parentCommentId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            body: self.body,
            isHidden: self.isHidden,
            articleId: self.$article.id,
            authorId: self.$author.id,
            parentCommentId: self.$parentComment.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension ArticleComment {
    struct CreateRequest: Content {
        var body: String
        var isHidden: Bool = false
        var articleId: UUID
        var authorId: UUID
        var parentCommentId: UUID?
    }

    struct UpdateRequest: Content {
        var body: String?
        var isHidden: Bool?
        var articleId: UUID??
        var authorId: UUID??
        var parentCommentId: UUID??
    }
}