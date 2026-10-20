import Vapor
import Fluent

struct TournamentRoundController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "tournament-rounds")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "api", "rounds", "{id}", "start", use: start)
        group.post(":id", "api", "rounds", "{id}", "complete", use: complete)
        group.post(":id", "api", "rounds", "{id}", "pairings", use: generatePairings)
        group.get(":id", "api", "rounds", "{id}", "time-expired", use: isTimeExpired)
    }

    private func find(_ req: Request) async throws -> TournamentRound {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TournamentRound.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TournamentRound not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TournamentRound.DTO] {
        return try await TournamentRound.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(TournamentRound.CreateRequest.self)
        let model = TournamentRound()
        model.roundNumber = input.roundNumber
        model.status = input.status
        model.startedAt = input.startedAt
        model.endedAt = input.endedAt
        model.timeLimitMinutes = input.timeLimitMinutes
        model.$tournament.id = input.tournamentId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TournamentRound.DTO {
        return try await find(req).toDTO()
    }

    func start(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement start
        return .ok
    }

    func complete(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement complete
        return .ok
    }

    func generatePairings(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement generate_pairings
        return .ok
    }

    func isTimeExpired(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_time_expired
        throw Abort(.notImplemented)
    }

}

extension TournamentRound.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}