import Vapor
import Fluent

struct PlayerCollectionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "player-collections")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.patch(":id", use: patch)
        group.delete(":id", use: delete)
        group.post(":id", "api", "collection", "{id}", "add", use: add)
        group.post(":id", "api", "collection", "{id}", "remove", use: remove)
        group.get(":id", "api", "collection", "{id}", "value", use: estimatedValue)
    }

    private func find(_ req: Request) async throws -> PlayerCollection {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await PlayerCollection.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "PlayerCollection not found")
        }
        return model
    }

    func index(req: Request) async throws -> [PlayerCollection.DTO] {
        return try await PlayerCollection.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(PlayerCollection.CreateRequest.self)
        let model = PlayerCollection()
        model.quantity = input.quantity
        model.foil = input.foil
        model.condition = input.condition
        model.acquiredAt = input.acquiredAt
        model.acquiredVia = input.acquiredVia
        model.$player.id = input.playerId
        model.$card.id = input.cardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> PlayerCollection.DTO {
        return try await find(req).toDTO()
    }

    func patch(req: Request) async throws -> PlayerCollection.DTO {
        let input = try req.content.decode(PlayerCollection.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.quantity { model.quantity = v }
        if let v = input.foil { model.foil = v }
        if let v = input.condition { model.condition = v }
        if let v = input.acquiredAt { model.acquiredAt = v }
        if let v = input.acquiredVia { model.acquiredVia = v }
        if let vv = input.playerId, let v = vv { model.$player.id = v }
        if let vv = input.cardId, let v = vv { model.$card.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func add(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let quantity = try req.content.get(Int.self, at: "quantity")
        // TODO: implement add
        return .ok
    }

    func remove(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let quantity = try req.content.get(Int.self, at: "quantity")
        // TODO: implement remove
        return .ok
    }

    func estimatedValue(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement estimated_value
        throw Abort(.notImplemented)
    }

}

extension PlayerCollection.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}