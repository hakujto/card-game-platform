import Vapor
import Fluent

struct TournamentPrizeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "tournament-prizes")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.delete(":id", use: delete)
        group.get(":id", "api", "prizes", "{id}", "applies", use: appliesToPlacement)
        group.post(":id", "api", "prizes", "{id}", "award", use: awardToPlayer)
    }

    private func find(_ req: Request) async throws -> TournamentPrize {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TournamentPrize.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TournamentPrize not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TournamentPrize.DTO] {
        return try await TournamentPrize.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try TournamentPrize.CreateRequest.validate(content: req)
        let input = try req.content.decode(TournamentPrize.CreateRequest.self)
        let model = TournamentPrize()
        model.placementFrom = input.placementFrom
        model.placementTo = input.placementTo
        model.prizeType = input.prizeType
        model.amount = input.amount
        model.description = input.description
        model.packsCount = input.packsCount
        model.seasonPoints = input.seasonPoints
        model.$tournament.id = input.tournamentId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TournamentPrize.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> TournamentPrize.DTO {
        let input = try req.content.decode(TournamentPrize.CreateRequest.self)
        let model = try await find(req)
        model.placementFrom = input.placementFrom
        model.placementTo = input.placementTo
        model.prizeType = input.prizeType
        model.amount = input.amount
        model.description = input.description
        model.packsCount = input.packsCount
        model.seasonPoints = input.seasonPoints
        model.$tournament.id = input.tournamentId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> TournamentPrize.DTO {
        let input = try req.content.decode(TournamentPrize.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.placementFrom { model.placementFrom = v }
        if let v = input.placementTo { model.placementTo = v }
        if let v = input.prizeType { model.prizeType = v }
        if let v = input.amount { model.amount = v }
        if let v = input.description { model.description = v }
        if let v = input.packsCount { model.packsCount = v }
        if let v = input.seasonPoints { model.seasonPoints = v }
        if let vv = input.tournamentId, let v = vv { model.$tournament.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func appliesToPlacement(req: Request) async throws -> Response {
        let model = try await find(req)
        let placement = try req.content.get(Int.self, at: "placement")
        // TODO: implement applies_to_placement
        throw Abort(.notImplemented)
    }

    func awardToPlayer(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let playerId = try req.content.get(Int.self, at: "player_id")
        // TODO: implement award_to_player
        return .ok
    }

}

extension TournamentPrize.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("placementFrom", as: Int.self, is: .range(1...))
        validations.add("placementTo", as: Int.self, is: .range(1...))
    }
}