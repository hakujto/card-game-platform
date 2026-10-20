import Vapor
import Fluent

struct CardAbilityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "card-abilities")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.delete(":id", use: delete)
        group.get(":id", "usable", use: isUsableAt)
        group.get(":id", "describe", use: describe)
    }

    private func find(_ req: Request) async throws -> CardAbility {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await CardAbility.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "CardAbility not found")
        }
        return model
    }

    func index(req: Request) async throws -> [CardAbility.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = CardAbility.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("keyword", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("ability_text", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CardAbility.CreateRequest.self)
        let model = CardAbility()
        model.abilityType = input.abilityType
        model.keyword = input.keyword
        model.abilityText = input.abilityText
        model.timing = input.timing
        model.$card.id = input.cardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> CardAbility.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> CardAbility.DTO {
        let input = try req.content.decode(CardAbility.CreateRequest.self)
        let model = try await find(req)
        model.abilityType = input.abilityType
        model.keyword = input.keyword
        model.abilityText = input.abilityText
        model.timing = input.timing
        model.$card.id = input.cardId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> CardAbility.DTO {
        let input = try req.content.decode(CardAbility.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.abilityType { model.abilityType = v }
        if let v = input.keyword { model.keyword = v }
        if let v = input.abilityText { model.abilityText = v }
        if let v = input.timing { model.timing = v }
        if let vv = input.cardId, let v = vv { model.$card.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func isUsableAt(req: Request) async throws -> Response {
        let model = try await find(req)
        let timing = try req.content.get(String.self, at: "timing")
        // TODO: implement is_usable_at
        throw Abort(.notImplemented)
    }

    func describe(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement describe
        throw Abort(.notImplemented)
    }

}

extension CardAbility.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}