import Vapor
import Fluent

struct CardSetController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "card-sets")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.get(":id", "standard-legal", use: isLegalInStandard)
        group.get(":id", "legal", use: isLegalInFormat)
        group.get(":id", "rarity-count", use: cardCountByRarity)
        group.post(":id", "rotate", use: rotateOut)
    }

    private func find(_ req: Request) async throws -> CardSet {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await CardSet.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "CardSet not found")
        }
        return model
    }

    func index(req: Request) async throws -> [CardSet.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = CardSet.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("code", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try CardSet.CreateRequest.validate(content: req)
        let input = try req.content.decode(CardSet.CreateRequest.self)
        let model = CardSet()
        model.name = input.name
        model.code = input.code
        model.releaseDate = input.releaseDate
        model.rotationDate = input.rotationDate
        model.setType = input.setType
        model.totalCards = input.totalCards
        model.isRotated = input.isRotated
        model.description = input.description
        model.logoUrl = input.logoUrl
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> CardSet.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> CardSet.DTO {
        let input = try req.content.decode(CardSet.CreateRequest.self)
        let model = try await find(req)
        model.name = input.name
        model.code = input.code
        model.releaseDate = input.releaseDate
        model.rotationDate = input.rotationDate
        model.setType = input.setType
        model.totalCards = input.totalCards
        model.isRotated = input.isRotated
        model.description = input.description
        model.logoUrl = input.logoUrl
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> CardSet.DTO {
        let input = try req.content.decode(CardSet.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.name { model.name = v }
        if let v = input.code { model.code = v }
        if let v = input.releaseDate { model.releaseDate = v }
        if let v = input.rotationDate { model.rotationDate = v }
        if let v = input.setType { model.setType = v }
        if let v = input.totalCards { model.totalCards = v }
        if let v = input.isRotated { model.isRotated = v }
        if let v = input.description { model.description = v }
        if let v = input.logoUrl { model.logoUrl = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func isLegalInStandard(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_legal_in_standard
        throw Abort(.notImplemented)
    }

    func isLegalInFormat(req: Request) async throws -> Response {
        let model = try await find(req)
        let format = try req.content.get(String.self, at: "format")
        // TODO: implement is_legal_in_format
        throw Abort(.notImplemented)
    }

    func cardCountByRarity(req: Request) async throws -> Response {
        let model = try await find(req)
        let rarity = try req.content.get(String.self, at: "rarity")
        // TODO: implement card_count_by_rarity
        throw Abort(.notImplemented)
    }

    func rotateOut(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement rotate_out
        return .ok
    }

}

extension CardSet.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("code", as: String.self, is: .pattern("[A-Z]{2,6}"))
    }
}