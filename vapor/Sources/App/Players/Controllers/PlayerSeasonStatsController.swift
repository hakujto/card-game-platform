import Vapor
import Fluent

struct PlayerSeasonStatsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "player-season-statses")
        group.get(use: index)
        group.get(":id", use: show)
        group.get(":id", "api", "player-season-stats", "{id}", "win-rate", use: winRate)
        group.patch(":id", "api", "player-season-stats", "{id}", "points", use: addPoints)
        group.post(":id", "api", "player-season-stats", "{id}", "tournament-win", use: recordTournamentWin)
    }

    private func find(_ req: Request) async throws -> PlayerSeasonStats {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await PlayerSeasonStats.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "PlayerSeasonStats not found")
        }
        return model
    }

    func index(req: Request) async throws -> [PlayerSeasonStats.DTO] {
        return try await PlayerSeasonStats.query(on: req.db).all().map { $0.toDTO() }
    }

    func show(req: Request) async throws -> PlayerSeasonStats.DTO {
        return try await find(req).toDTO()
    }

    func winRate(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement win_rate
        throw Abort(.notImplemented)
    }

    func addPoints(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let points = try req.content.get(Int.self, at: "points")
        // TODO: implement add_points
        return .ok
    }

    func recordTournamentWin(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement record_tournament_win
        return .ok
    }

}

extension PlayerSeasonStats.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}