import Vapor
import Fluent

struct DeckController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "decks")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.delete(":id", use: delete)
        group.get(":id", "validate", use: validateSize)
        group.post(":id", "cards", use: addCard)
        group.delete(":id", "cards", "{card_id}", use: removeCard)
        group.get(":id", "win-rate", use: winRate)
        group.post(":id", "clone", use: clone)
        group.post(":id", "publish", use: publish)
        group.post(":id", "unpublish", use: unpublish)
        group.post(":id", "certify", use: certifyTournamentLegal)
    }

    private func find(_ req: Request) async throws -> Deck {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Deck.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Deck not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Deck.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Deck.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("description", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Deck.CreateRequest.self)
        let model = Deck()
        model.name = input.name
        model.description = input.description
        model.format = input.format
        model.isPublic = input.isPublic
        model.isTournamentLegal = input.isTournamentLegal
        model.archetype = input.archetype
        model.wins = input.wins
        model.losses = input.losses
        model.draws = input.draws
        model.$player.id = input.playerId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Deck.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Deck.DTO {
        let input = try req.content.decode(Deck.CreateRequest.self)
        let model = try await find(req)
        model.name = input.name
        model.description = input.description
        model.format = input.format
        model.isPublic = input.isPublic
        model.isTournamentLegal = input.isTournamentLegal
        model.archetype = input.archetype
        model.wins = input.wins
        model.losses = input.losses
        model.draws = input.draws
        model.$player.id = input.playerId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Deck.DTO {
        let input = try req.content.decode(Deck.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.name { model.name = v }
        if let v = input.description { model.description = v }
        if let v = input.format { model.format = v }
        if let v = input.isPublic { model.isPublic = v }
        if let v = input.isTournamentLegal { model.isTournamentLegal = v }
        if let v = input.archetype { model.archetype = v }
        if let vv = input.playerId, let v = vv { model.$player.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func validateSize(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement validate_size
        throw Abort(.notImplemented)
    }

    func addCard(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let cardId = try req.content.get(Int.self, at: "card_id")
        let quantity = try req.content.get(Int.self, at: "quantity")
        // TODO: implement add_card
        return .ok
    }

    func removeCard(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let cardId = try req.content.get(Int.self, at: "card_id")
        // TODO: implement remove_card
        return .ok
    }

    func winRate(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement win_rate
        throw Abort(.notImplemented)
    }

    func clone(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement clone
        throw Abort(.notImplemented)
    }

    func publish(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement publish
        return .ok
    }

    func unpublish(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement unpublish
        return .ok
    }

    func certifyTournamentLegal(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement certify_tournament_legal
        throw Abort(.notImplemented)
    }

}

extension Deck.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}