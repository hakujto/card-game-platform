import Vapor
import Fluent

struct TournamentJudgeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "tournament-judges")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
        group.post(":id", "promote", use: promoteToHead)
    }

    private func find(_ req: Request) async throws -> TournamentJudge {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TournamentJudge.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TournamentJudge not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TournamentJudge.DTO] {
        return try await TournamentJudge.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(TournamentJudge.CreateRequest.self)
        let model = TournamentJudge()
        model.role = input.role
        model.$tournament.id = input.tournamentId
        model.$player.id = input.playerId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TournamentJudge.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func promoteToHead(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement promote_to_head
        return .ok
    }

    func remove(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement remove
        return .ok
    }

}