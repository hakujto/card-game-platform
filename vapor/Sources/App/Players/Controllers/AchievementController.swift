import Vapor
import Fluent

struct AchievementController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "achievements")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.get(":id", "point-value", use: pointValue)
        group.post(":id", "reveal", use: reveal)
    }

    private func find(_ req: Request) async throws -> Achievement {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Achievement.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Achievement not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Achievement.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Achievement.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("description", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Achievement.CreateRequest.self)
        let model = Achievement()
        model.name = input.name
        model.description = input.description
        model.iconUrl = input.iconUrl
        model.points = input.points
        model.rarity = input.rarity
        model.isHidden = input.isHidden
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Achievement.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Achievement.DTO {
        let input = try req.content.decode(Achievement.CreateRequest.self)
        let model = try await find(req)
        model.name = input.name
        model.description = input.description
        model.iconUrl = input.iconUrl
        model.points = input.points
        model.rarity = input.rarity
        model.isHidden = input.isHidden
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Achievement.DTO {
        let input = try req.content.decode(Achievement.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.name { model.name = v }
        if let v = input.description { model.description = v }
        if let v = input.iconUrl { model.iconUrl = v }
        if let v = input.points { model.points = v }
        if let v = input.rarity { model.rarity = v }
        if let v = input.isHidden { model.isHidden = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func pointValue(req: Request) async throws -> Response {
        let model = try await find(req)
        let multiplier = try req.content.get(Int.self, at: "multiplier")
        // TODO: implement point_value
        throw Abort(.notImplemented)
    }

    func reveal(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement reveal
        return .ok
    }

}

extension Achievement.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}