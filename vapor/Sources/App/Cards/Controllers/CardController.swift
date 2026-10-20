import Vapor
import Fluent

struct CardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "cards")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.post(":id", "ban", use: ban)
        group.post(":id", "unban", use: unban)
        group.post(":id", "restrict", use: restrict)
        group.post(":id", "unrestrict", use: unrestrict)
        group.get(":id", "value", use: calculateValue)
        group.post(":id", "rarity-bonus", use: applyRarityBonus)
        group.get(":id", "legal", use: isLegalInFormat)
    }

    private func find(_ req: Request) async throws -> Card {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Card.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Card not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Card.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Card.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("artist_name", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Card.CreateRequest.validate(content: req)
        let input = try req.content.decode(Card.CreateRequest.self)
        if input.cardType == .creature && input.attack == nil { throw Abort(.badRequest, reason: "attack is required") }
        if input.cardType == .creature && input.defense == nil { throw Abort(.badRequest, reason: "defense is required") }
        if input.cardType == .planeswalker && input.loyalty == nil { throw Abort(.badRequest, reason: "loyalty is required") }
        let model = Card()
        model.publicId = input.publicId
        model.name = input.name
        model.cardType = input.cardType
        model.rarity = input.rarity
        model.manaCost = input.manaCost
        model.manaColors = input.manaColors
        model.attack = input.attack
        model.defense = input.defense
        model.loyalty = input.loyalty
        model.description = input.description
        model.flavorText = input.flavorText
        model.imageUrl = input.imageUrl
        model.artistName = input.artistName
        model.legalFormats = input.legalFormats
        model.isBanned = input.isBanned
        model.isRestricted = input.isRestricted
        model.powerLevel = input.powerLevel
        model.metadata = input.metadata
        model.totalCopiesInCirculation = input.totalCopiesInCirculation
        model.$set.id = input.setId
        try await model.save(on: req.db)
        // TODO: audit log — track create
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Card.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Card.DTO {
        let input = try req.content.decode(Card.CreateRequest.self)
        let model = try await find(req)
        model.publicId = input.publicId
        model.name = input.name
        model.cardType = input.cardType
        model.rarity = input.rarity
        model.manaCost = input.manaCost
        model.manaColors = input.manaColors
        model.attack = input.attack
        model.defense = input.defense
        model.loyalty = input.loyalty
        model.description = input.description
        model.flavorText = input.flavorText
        model.imageUrl = input.imageUrl
        model.artistName = input.artistName
        model.legalFormats = input.legalFormats
        model.isBanned = input.isBanned
        model.isRestricted = input.isRestricted
        model.powerLevel = input.powerLevel
        model.metadata = input.metadata
        model.totalCopiesInCirculation = input.totalCopiesInCirculation
        model.$set.id = input.setId
        try await model.update(on: req.db)
        // TODO: audit log — track update
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Card.DTO {
        let input = try req.content.decode(Card.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.publicId { model.publicId = v }
        if let v = input.name { model.name = v }
        if let v = input.cardType { model.cardType = v }
        if let v = input.rarity { model.rarity = v }
        if let v = input.manaCost { model.manaCost = v }
        if let v = input.manaColors { model.manaColors = v }
        if let v = input.attack { model.attack = v }
        if let v = input.defense { model.defense = v }
        if let v = input.loyalty { model.loyalty = v }
        if let v = input.description { model.description = v }
        if let v = input.flavorText { model.flavorText = v }
        if let v = input.imageUrl { model.imageUrl = v }
        if let v = input.artistName { model.artistName = v }
        if let v = input.legalFormats { model.legalFormats = v }
        if let v = input.powerLevel { model.powerLevel = v }
        if let v = input.metadata { model.metadata = v }
        if let v = input.totalCopiesInCirculation { model.totalCopiesInCirculation = v }
        if let vv = input.setId, let v = vv { model.$set.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func ban(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement ban
        return .ok
    }

    func unban(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement unban
        return .ok
    }

    func restrict(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement restrict
        return .ok
    }

    func unrestrict(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement unrestrict
        return .ok
    }

    func replace(req: Request) async throws -> Response {
        let model = try await find(req)
        let data = try req.content.get(String.self, at: "data")
        // TODO: implement replace
        throw Abort(.notImplemented)
    }

    func calculateValue(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement calculate_value
        throw Abort(.notImplemented)
    }

    func applyRarityBonus(req: Request) async throws -> Response {
        let model = try await find(req)
        let multiplier = try req.content.get(Int.self, at: "multiplier")
        // TODO: implement apply_rarity_bonus
        throw Abort(.notImplemented)
    }

    func isLegalInFormat(req: Request) async throws -> Response {
        let model = try await find(req)
        let format = try req.content.get(String.self, at: "format")
        // TODO: implement is_legal_in_format
        throw Abort(.notImplemented)
    }

}

extension Card.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("manaCost", as: Int.self, is: .range(0...))
        validations.add("manaCost", as: Int.self, is: .range(...20))
        validations.add("powerLevel", as: Int.self, is: .range(1...))
        validations.add("powerLevel", as: Int.self, is: .range(...10))
    }
}