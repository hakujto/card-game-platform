import Vapor
import Fluent

struct ArticleTagAssignmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "article-tag-assignments")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
    }

    private func find(_ req: Request) async throws -> ArticleTagAssignment {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await ArticleTagAssignment.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "ArticleTagAssignment not found")
        }
        return model
    }

    func index(req: Request) async throws -> [ArticleTagAssignment.DTO] {
        return try await ArticleTagAssignment.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(ArticleTagAssignment.CreateRequest.self)
        let model = ArticleTagAssignment()
        model.$article.id = input.articleId
        model.$tag.id = input.tagId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> ArticleTagAssignment.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

}