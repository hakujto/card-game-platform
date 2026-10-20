import Vapor
import Fluent

struct GameController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "games")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "winner", use: recordWinner)
        group.get(":id", "duration", use: durationMinutes)
    }

    private func find(_ req: Request) async throws -> Game {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Game.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Game not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Game.DTO] {
        return try await Game.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Game.CreateRequest.validate(content: req)
        let input = try req.content.decode(Game.CreateRequest.self)
        let model = Game()
        model.gameNumber = input.gameNumber
        model.winnerSide = input.winnerSide
        model.complexityScore = input.complexityScore
        model.turnsPlayed = input.turnsPlayed
        model.durationSeconds = input.durationSeconds
        model.endedBy = input.endedBy
        model.replayUrl = input.replayUrl
        model.$match.id = input.matchId
        model.$winner.id = input.winnerId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Game.DTO {
        return try await find(req).toDTO()
    }

    func recordWinner(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let winnerSide = try req.content.get(String.self, at: "winner_side")
        // TODO: implement record_winner
        return .ok
    }

    func durationMinutes(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement duration_minutes
        throw Abort(.notImplemented)
    }

}

extension Game.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("gameNumber", as: Int.self, is: .range(1...))
        validations.add("gameNumber", as: Int.self, is: .range(...3))
    }
}