import Vapor
import Fluent

struct ArticleCommentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "article-comments")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
        group.post(":id", "api", "comments", "{id}", "hide", use: hide)
        group.post(":id", "api", "comments", "{id}", "unhide", use: unhide)
        group.get(":id", "api", "comments", "{id}", "is-reply", use: isReply)
    }

    private func find(_ req: Request) async throws -> ArticleComment {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await ArticleComment.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "ArticleComment not found")
        }
        return model
    }

    func index(req: Request) async throws -> [ArticleComment.DTO] {
        return try await ArticleComment.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(ArticleComment.CreateRequest.self)
        let model = ArticleComment()
        model.body = input.body
        model.isHidden = input.isHidden
        model.$article.id = input.articleId
        model.$author.id = input.authorId
        model.$parentComment.id = input.parentCommentId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> ArticleComment.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func hide(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement hide
        return .ok
    }

    func unhide(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement unhide
        return .ok
    }

    func isReply(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_reply
        throw Abort(.notImplemented)
    }

}