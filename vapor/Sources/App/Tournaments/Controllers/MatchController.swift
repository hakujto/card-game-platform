import Vapor
import Fluent

struct MatchController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "matches")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "record", use: recordResult)
        group.post(":id", "finalize", use: finalizeResult)
        group.get(":id", "winner", use: determineWinner)
        group.post(":id", "concede", use: concede)
        group.post(":id", "draw", use: draw)
        group.patch(":id", "transitions", "pending-to-active", use: transitionPendingToActive)
        group.patch(":id", "transitions", "active-to-completed", use: transitionActiveToCompleted)
        group.patch(":id", "transitions", "active-to-draw", use: transitionActiveToDraw)
        group.patch(":id", "transitions", "pending-to-bye", use: transitionPendingToBYE)
    }

    private func find(_ req: Request) async throws -> Match {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Match.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Match not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Match.DTO] {
        return try await Match.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Match.CreateRequest.self)
        let model = Match()
        model.tableNumber = input.tableNumber
        model.status = input.status
        model.player1Wins = input.player1Wins
        model.player2Wins = input.player2Wins
        model.startedAt = input.startedAt
        model.endedAt = input.endedAt
        model.resultNotes = input.resultNotes
        model.$round.id = input.roundId
        model.$player1.id = input.player1Id
        model.$player2.id = input.player2Id
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Match.DTO {
        return try await find(req).toDTO()
    }

    func recordResult(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let p1Wins = try req.content.get(Int.self, at: "p1_wins")
        let p2Wins = try req.content.get(Int.self, at: "p2_wins")
        // TODO: implement record_result
        // @after: try await determineWinner(req: req)
        return .ok
    }

    func finalizeResult(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement finalize_result
        // @after: try await determineWinner(req: req)
        return .ok
    }

    func determineWinner(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement determine_winner
        throw Abort(.notImplemented)
    }

    func concede(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        guard model.status == .active else { throw Abort(.forbidden, reason: "Guard condition not met for concede") }
        let playerId = try req.content.get(Int.self, at: "player_id")
        // TODO: implement concede
        return .ok
    }

    func draw(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement draw
        return .ok
    }

    func transitionPendingToActive(req: Request) async throws -> Match.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Pending to Active
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionActiveToCompleted(req: Request) async throws -> Match.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Active to Completed
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionActiveToDraw(req: Request) async throws -> Match.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Active to Draw
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionPendingToBYE(req: Request) async throws -> Match.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Pending to BYE
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension Match.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}