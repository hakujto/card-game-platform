import Vapor
import Fluent

enum ArticleStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case published = "Published"
    case archived = "Archived"
}

enum ArticleArticleType: String, Codable, CaseIterable {
    case guide = "Guide"
    case tierlist = "Tierlist"
    case matchup = "Matchup"
    case news = "News"
    case spotlight = "Spotlight"
    case decklist = "Decklist"
}

enum ArticleLanguage: String, Codable, CaseIterable {
    case eN = "EN"
    case dE = "DE"
    case fR = "FR"
    case iT = "IT"
    case eS = "ES"
    case jP = "JP"
    case pT = "PT"
}

// Hook: after_save → update_search_index

final class Article: Model, Content {
    static let schema = "articles"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "slug")
    var slug: String

    @Field(key: "body")
    var body: String

    @OptionalField(key: "excerpt")
    var excerpt: String?

    @OptionalField(key: "cover_image_url")
    var coverImageUrl: String?

    @Field(key: "status")
    var status: ArticleStatus

    @Field(key: "article_type")
    var articleType: ArticleArticleType

    @Field(key: "language")
    var language: ArticleLanguage

    @Field(key: "view_count")
    var viewCount: Int

    @Field(key: "likes_count")
    var likesCount: Int

    @Field(key: "total_views_alltime")
    var totalViewsAlltime: Int

    @Field(key: "is_featured")
    var isFeatured: Bool

    @OptionalField(key: "published_at")
    var publishedAt: Date?

    @Parent(key: "author_id")
    var author: Player

    @OptionalParent(key: "featured_deck_id")
    var featuredDeck: Deck?

    @Siblings(through: ArticleTagAssignment.self, from: \ArticleTagAssignment.$article, to: \ArticleTagAssignment.$tag)
    var tags: [ArticleTag]

    @Children(for: \ArticleTagAssignment.$article)
    var tagAssignments: [ArticleTagAssignment]

    @Children(for: \ArticleComment.$article)
    var comments: [ArticleComment]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        title: String,
        slug: String,
        body: String,
        excerpt: String?,
        coverImageUrl: String?,
        status: ArticleStatus = .draft,
        articleType: ArticleArticleType = .guide,
        language: ArticleLanguage = .eN,
        viewCount: Int = 0,
        likesCount: Int = 0,
        totalViewsAlltime: Int = 0,
        isFeatured: Bool = false,
        publishedAt: Date?,
        authorID: UUID,
        featuredDeckID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.slug = slug
        self.body = body
        self.excerpt = excerpt
        self.coverImageUrl = coverImageUrl
        self.status = status
        self.articleType = articleType
        self.language = language
        self.viewCount = viewCount
        self.likesCount = likesCount
        self.totalViewsAlltime = totalViewsAlltime
        self.isFeatured = isFeatured
        self.publishedAt = publishedAt
        self.$author.id = authorID
        self.$featuredDeck.id = featuredDeckID
    }

    struct DTO: Content {
        var id: UUID?
        var title: String
        var slug: String
        var body: String
        var excerpt: String?
        var coverImageUrl: String?
        var status: ArticleStatus
        var articleType: ArticleArticleType
        var language: ArticleLanguage
        var viewCount: Int
        var likesCount: Int
        var totalViewsAlltime: Int
        var isFeatured: Bool
        var publishedAt: Date?
        var authorId: UUID?
        var featuredDeckId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            title: self.title,
            slug: self.slug,
            body: self.body,
            excerpt: self.excerpt,
            coverImageUrl: self.coverImageUrl,
            status: self.status,
            articleType: self.articleType,
            language: self.language,
            viewCount: self.viewCount,
            likesCount: self.likesCount,
            totalViewsAlltime: self.totalViewsAlltime,
            isFeatured: self.isFeatured,
            publishedAt: self.publishedAt,
            authorId: self.$author.id,
            featuredDeckId: self.$featuredDeck.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Article {
    struct CreateRequest: Content {
        var title: String
        var slug: String
        var body: String
        var excerpt: String?
        var coverImageUrl: String?
        var status: ArticleStatus = .draft
        var articleType: ArticleArticleType = .guide
        var language: ArticleLanguage = .eN
        var viewCount: Int = 0
        var likesCount: Int = 0
        var totalViewsAlltime: Int = 0
        var isFeatured: Bool = false
        var publishedAt: Date?
        var authorId: UUID
        var featuredDeckId: UUID?
    }

    struct UpdateRequest: Content {
        var title: String?
        var slug: String?
        var body: String?
        var excerpt: String??
        var coverImageUrl: String??
        var articleType: ArticleArticleType?
        var language: ArticleLanguage?
        var totalViewsAlltime: Int?
        var isFeatured: Bool?
        var publishedAt: Date??
        var authorId: UUID??
        var featuredDeckId: UUID??
    }
}