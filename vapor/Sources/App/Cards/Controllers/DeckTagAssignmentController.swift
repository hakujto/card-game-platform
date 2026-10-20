import Vapor
import Fluent

struct DeckTagAssignmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "deck-tag-assignments")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
    }

    private func find(_ req: Request) async throws -> DeckTagAssignment {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await DeckTagAssignment.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "DeckTagAssignment not found")
        }
        return model
    }

    func index(req: Request) async throws -> [DeckTagAssignment.DTO] {
        return try await DeckTagAssignment.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(DeckTagAssignment.CreateRequest.self)
        let model = DeckTagAssignment()
        model.$deck.id = input.deckId
        model.$tag.id = input.tagId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> DeckTagAssignment.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

}