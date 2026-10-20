import Vapor
import Fluent

struct DeckCardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "deck-cards")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.patch(":id", use: patch)
        group.delete(":id", use: delete)
        group.patch(":id", "increment", use: increment)
        group.patch(":id", "decrement", use: decrement)
    }

    private func find(_ req: Request) async throws -> DeckCard {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await DeckCard.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "DeckCard not found")
        }
        return model
    }

    func index(req: Request) async throws -> [DeckCard.DTO] {
        return try await DeckCard.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try DeckCard.CreateRequest.validate(content: req)
        let input = try req.content.decode(DeckCard.CreateRequest.self)
        let model = DeckCard()
        model.quantity = input.quantity
        model.isCommander = input.isCommander
        model.$deck.id = input.deckId
        model.$card.id = input.cardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> DeckCard.DTO {
        return try await find(req).toDTO()
    }

    func patch(req: Request) async throws -> DeckCard.DTO {
        let input = try req.content.decode(DeckCard.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.quantity { model.quantity = v }
        if let v = input.isCommander { model.isCommander = v }
        if let vv = input.deckId, let v = vv { model.$deck.id = v }
        if let vv = input.cardId, let v = vv { model.$card.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func increment(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let amount = try req.content.get(Int.self, at: "amount")
        // TODO: implement increment
        return .ok
    }

    func decrement(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let amount = try req.content.get(Int.self, at: "amount")
        // TODO: implement decrement
        return .ok
    }

}

extension DeckCard.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("quantity", as: Int.self, is: .range(1...))
        validations.add("quantity", as: Int.self, is: .range(...4))
    }
}