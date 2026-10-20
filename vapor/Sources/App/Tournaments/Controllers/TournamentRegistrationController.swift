import Vapor
import Fluent

struct TournamentRegistrationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "tournament-registrations")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "api", "registrations", "{id}", "withdraw", use: withdraw)
        group.post(":id", "api", "registrations", "{id}", "disqualify", use: disqualify)
        group.post(":id", "api", "registrations", "{id}", "promote", use: promoteFromWaitlist)
    }

    private func find(_ req: Request) async throws -> TournamentRegistration {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TournamentRegistration.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TournamentRegistration not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TournamentRegistration.DTO] {
        return try await TournamentRegistration.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(TournamentRegistration.CreateRequest.self)
        let model = TournamentRegistration()
        model.status = input.status
        model.seed = input.seed
        model.finalStanding = input.finalStanding
        model.pointsEarned = input.pointsEarned
        model.registeredAt = input.registeredAt
        model.$tournament.id = input.tournamentId
        model.$player.id = input.playerId
        model.$deck.id = input.deckId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TournamentRegistration.DTO {
        return try await find(req).toDTO()
    }

    func withdraw(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement withdraw
        return .ok
    }

    func disqualify(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let reason = try req.content.get(String.self, at: "reason")
        // TODO: implement disqualify
        return .ok
    }

    func promoteFromWaitlist(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement promote_from_waitlist
        return .ok
    }

}

extension TournamentRegistration.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}