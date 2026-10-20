import Vapor
import Fluent

struct PlayerAchievementController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "player-achievements")
        group.get(use: index)
        group.get(":id", use: show)
        group.patch(":id", "progress", use: incrementProgress)
        group.post(":id", "complete", use: complete)
    }

    private func find(_ req: Request) async throws -> PlayerAchievement {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await PlayerAchievement.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "PlayerAchievement not found")
        }
        return model
    }

    func index(req: Request) async throws -> [PlayerAchievement.DTO] {
        return try await PlayerAchievement.query(on: req.db).all().map { $0.toDTO() }
    }

    func show(req: Request) async throws -> PlayerAchievement.DTO {
        return try await find(req).toDTO()
    }

    func incrementProgress(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let amount = try req.content.get(Int.self, at: "amount")
        // TODO: implement increment_progress
        return .ok
    }

    func complete(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement complete
        return .ok
    }

}

extension PlayerAchievement.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}