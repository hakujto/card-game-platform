import Vapor
import Fluent

struct TournamentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "tournaments")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.post(":id", "start", use: start)
        group.post(":id", "cancel", use: cancel)
        group.post(":id", "complete", use: complete)
        group.post(":id", "rounds", use: generateRound)
        group.get(":id", "prizes", use: calculatePrizeDistribution)
        group.post(":id", "register", use: registerPlayer)
        group.get(":id", "full", use: isFull)
        group.patch(":id", "transitions", "draft-to-registration", use: transitionDraftToRegistration)
        group.patch(":id", "transitions", "registration-to-ongoing", use: transitionRegistrationToOngoing)
        group.patch(":id", "transitions", "registration-to-cancelled", use: transitionRegistrationToCancelled)
        group.patch(":id", "transitions", "ongoing-to-completed", use: transitionOngoingToCompleted)
        group.patch(":id", "transitions", "ongoing-to-cancelled", use: transitionOngoingToCancelled)
    }

    private func find(_ req: Request) async throws -> Tournament {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Tournament.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Tournament not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Tournament.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Tournament.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("description", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Tournament.CreateRequest.validate(content: req)
        let input = try req.content.decode(Tournament.CreateRequest.self)
        let model = Tournament()
        model.publicId = input.publicId
        model.name = input.name
        model.description = input.description
        model.status = input.status
        model.bracketData = input.bracketData
        model.format = input.format
        model.tournamentType = input.tournamentType
        model.maxPlayers = input.maxPlayers
        model.entryFee = input.entryFee
        model.prizePool = input.prizePool
        model.startTime = input.startTime
        model.endTime = input.endTime
        model.isOnline = input.isOnline
        model.location = input.location
        model.rulesText = input.rulesText
        model.$season.id = input.seasonId
        model.$organizer.id = input.organizerId
        try await model.save(on: req.db)
        // TODO: audit log — track create
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Tournament.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Tournament.DTO {
        let input = try req.content.decode(Tournament.CreateRequest.self)
        let model = try await find(req)
        model.publicId = input.publicId
        model.name = input.name
        model.description = input.description
        model.status = input.status
        model.bracketData = input.bracketData
        model.format = input.format
        model.tournamentType = input.tournamentType
        model.maxPlayers = input.maxPlayers
        model.entryFee = input.entryFee
        model.prizePool = input.prizePool
        model.startTime = input.startTime
        model.endTime = input.endTime
        model.isOnline = input.isOnline
        model.location = input.location
        model.rulesText = input.rulesText
        model.$season.id = input.seasonId
        model.$organizer.id = input.organizerId
        try await model.update(on: req.db)
        // TODO: audit log — track update
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Tournament.DTO {
        let input = try req.content.decode(Tournament.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.publicId { model.publicId = v }
        if let v = input.name { model.name = v }
        if let v = input.description { model.description = v }
        if let v = input.bracketData { model.bracketData = v }
        if let v = input.format { model.format = v }
        if let v = input.tournamentType { model.tournamentType = v }
        if let v = input.maxPlayers { model.maxPlayers = v }
        if let v = input.entryFee { model.entryFee = v }
        if let v = input.prizePool { model.prizePool = v }
        if let v = input.startTime { model.startTime = v }
        if let v = input.endTime { model.endTime = v }
        if let v = input.isOnline { model.isOnline = v }
        if let v = input.location { model.location = v }
        if let v = input.rulesText { model.rulesText = v }
        if let vv = input.seasonId, let v = vv { model.$season.id = v }
        if let vv = input.organizerId, let v = vv { model.$organizer.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func start(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement start
        return .ok
    }

    func cancel(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement cancel
        return .ok
    }

    func complete(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement complete
        return .ok
    }

    func generateRound(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement generate_round
        return .ok
    }

    func calculatePrizeDistribution(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement calculate_prize_distribution
        throw Abort(.notImplemented)
    }

    func registerPlayer(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let playerId = try req.content.get(Int.self, at: "player_id")
        let deckId = try req.content.get(Int.self, at: "deck_id")
        // TODO: implement register_player
        return .ok
    }

    func isFull(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_full
        throw Abort(.notImplemented)
    }

    func transitionDraftToRegistration(req: Request) async throws -> Tournament.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Draft to Registration
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionRegistrationToOngoing(req: Request) async throws -> Tournament.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Registration to Ongoing
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionRegistrationToCancelled(req: Request) async throws -> Tournament.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Registration to Cancelled
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionOngoingToCompleted(req: Request) async throws -> Tournament.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Ongoing to Completed
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionOngoingToCancelled(req: Request) async throws -> Tournament.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Ongoing to Cancelled
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension Tournament.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("maxPlayers", as: Int.self, is: .range(2...))
        validations.add("maxPlayers", as: Int.self, is: .range(...512))
    }
}