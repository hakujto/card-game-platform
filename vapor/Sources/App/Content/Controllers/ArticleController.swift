import Vapor
import Fluent

struct ArticleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "articles")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.post(":id", "publish", use: publish)
        group.post(":id", "archive", use: archive)
        group.post(":id", "view", use: incrementView)
        group.post(":id", "like", use: like)
        group.delete(":id", "like", use: unlike)
        group.get(":id", "reading-time", use: readingTimeMinutes)
        group.patch(":id", "transitions", "draft-to-published", use: transitionDraftToPublished)
        group.patch(":id", "transitions", "published-to-archived", use: transitionPublishedToArchived)
        group.patch(":id", "transitions", "archived-to-draft", use: transitionArchivedToDraft)
    }

    private func find(_ req: Request) async throws -> Article {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Article.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Article not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Article.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Article.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("title", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("excerpt", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Article.CreateRequest.self)
        let model = Article()
        model.title = input.title
        model.slug = input.slug
        model.body = input.body
        model.excerpt = input.excerpt
        model.coverImageUrl = input.coverImageUrl
        model.status = input.status
        model.articleType = input.articleType
        model.language = input.language
        model.viewCount = input.viewCount
        model.likesCount = input.likesCount
        model.totalViewsAlltime = input.totalViewsAlltime
        model.isFeatured = input.isFeatured
        model.publishedAt = input.publishedAt
        model.$author.id = input.authorId
        model.$featuredDeck.id = input.featuredDeckId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Article.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Article.DTO {
        let input = try req.content.decode(Article.CreateRequest.self)
        let model = try await find(req)
        model.title = input.title
        model.slug = input.slug
        model.body = input.body
        model.excerpt = input.excerpt
        model.coverImageUrl = input.coverImageUrl
        model.status = input.status
        model.articleType = input.articleType
        model.language = input.language
        model.viewCount = input.viewCount
        model.likesCount = input.likesCount
        model.totalViewsAlltime = input.totalViewsAlltime
        model.isFeatured = input.isFeatured
        model.publishedAt = input.publishedAt
        model.$author.id = input.authorId
        model.$featuredDeck.id = input.featuredDeckId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Article.DTO {
        let input = try req.content.decode(Article.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.title { model.title = v }
        if let v = input.slug { model.slug = v }
        if let v = input.body { model.body = v }
        if let v = input.excerpt { model.excerpt = v }
        if let v = input.coverImageUrl { model.coverImageUrl = v }
        if let v = input.articleType { model.articleType = v }
        if let v = input.language { model.language = v }
        if let v = input.totalViewsAlltime { model.totalViewsAlltime = v }
        if let v = input.isFeatured { model.isFeatured = v }
        if let v = input.publishedAt { model.publishedAt = v }
        if let vv = input.authorId, let v = vv { model.$author.id = v }
        if let vv = input.featuredDeckId, let v = vv { model.$featuredDeck.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func publish(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement publish
        return .ok
    }

    func archive(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement archive
        return .ok
    }

    func replace(req: Request) async throws -> Response {
        let model = try await find(req)
        let data = try req.content.get(String.self, at: "data")
        // TODO: implement replace
        throw Abort(.notImplemented)
    }

    func incrementView(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement increment_view
        return .ok
    }

    func like(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement like
        return .ok
    }

    func unlike(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement unlike
        return .ok
    }

    func readingTimeMinutes(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement reading_time_minutes
        throw Abort(.notImplemented)
    }

    func transitionDraftToPublished(req: Request) async throws -> Article.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Draft to Published
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionPublishedToArchived(req: Request) async throws -> Article.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Published to Archived
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionArchivedToDraft(req: Request) async throws -> Article.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Archived to Draft
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension Article.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}