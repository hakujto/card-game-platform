import Vapor
import Fluent

struct SeasonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "seasons")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.post(":id", "activate", use: activate)
        group.post(":id", "deactivate", use: deactivate)
        group.post(":id", "finalize", use: finalizeRewards)
        group.get(":id", "ongoing", use: isOngoing)
    }

    private func find(_ req: Request) async throws -> Season {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Season.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Season not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Season.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Season.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Season.CreateRequest.self)
        let model = Season()
        model.name = input.name
        model.startDate = input.startDate
        model.endDate = input.endDate
        model.format = input.format
        model.isActive = input.isActive
        model.rewardDescription = input.rewardDescription
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Season.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Season.DTO {
        let input = try req.content.decode(Season.CreateRequest.self)
        let model = try await find(req)
        model.name = input.name
        model.startDate = input.startDate
        model.endDate = input.endDate
        model.format = input.format
        model.isActive = input.isActive
        model.rewardDescription = input.rewardDescription
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Season.DTO {
        let input = try req.content.decode(Season.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.name { model.name = v }
        if let v = input.startDate { model.startDate = v }
        if let v = input.endDate { model.endDate = v }
        if let v = input.format { model.format = v }
        if let v = input.isActive { model.isActive = v }
        if let v = input.rewardDescription { model.rewardDescription = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func activate(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement activate
        return .ok
    }

    func deactivate(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement deactivate
        return .ok
    }

    func finalizeRewards(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement finalize_rewards
        return .ok
    }

    func isOngoing(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_ongoing
        throw Abort(.notImplemented)
    }

}

extension Season.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}