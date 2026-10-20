import Vapor
import Fluent

final class ArticleTag: Model, Content {
    static let schema = "article_tags"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "slug")
    var slug: String

    @Children(for: \ArticleTagAssignment.$tag)
    var articleAssignments: [ArticleTagAssignment]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        slug: String
    ) {
        self.id = id
        self.name = name
        self.slug = slug
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var slug: String
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            slug: self.slug,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension ArticleTag {
    struct CreateRequest: Content {
        var name: String
        var slug: String
    }

    struct UpdateRequest: Content {
        var name: String?
        var slug: String?
    }
}