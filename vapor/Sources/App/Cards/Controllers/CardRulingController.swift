import Vapor
import Fluent

struct CardRulingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "card-rulings")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
        group.get(":id", "current", use: isCurrent)
        group.get(":id", "supersedes", use: supersedesPrevious)
    }

    private func find(_ req: Request) async throws -> CardRuling {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await CardRuling.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "CardRuling not found")
        }
        return model
    }

    func index(req: Request) async throws -> [CardRuling.DTO] {
        return try await CardRuling.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CardRuling.CreateRequest.self)
        let model = CardRuling()
        model.rulingText = input.rulingText
        model.publishedAt = input.publishedAt
        model.source = input.source
        model.$card.id = input.cardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> CardRuling.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func isCurrent(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_current
        throw Abort(.notImplemented)
    }

    func supersedesPrevious(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement supersedes_previous
        throw Abort(.notImplemented)
    }

}