import Vapor
import Fluent

struct PlayerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "players")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.patch(":id", use: patch)
        group.post(":id", "promote", use: promote)
        group.post(":id", "demote", use: demote)
        group.post(":id", "win", use: recordWin)
        group.post(":id", "loss", use: recordLoss)
        group.get(":id", "win-rate", use: winRate)
        group.post(":id", "verify", use: verify)
        group.patch(":id", "rating", use: updateRating)
    }

    private func find(_ req: Request) async throws -> Player {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Player.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Player not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Player.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Player.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("display_name", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Player.CreateRequest.validate(content: req)
        let input = try req.content.decode(Player.CreateRequest.self)
        let model = Player()
        model.publicId = input.publicId
        model.displayName = input.displayName
        model.rank = input.rank
        model.rating = input.rating
        model.peakRating = input.peakRating
        model.bio = input.bio
        model.countryCode = input.countryCode
        model.avatarUrl = input.avatarUrl
        model.preferredFormat = input.preferredFormat
        model.contactEmail = input.contactEmail
        model.winRateCached = input.winRateCached
        model.isVerified = input.isVerified
        model.lastActiveAt = input.lastActiveAt
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Player.DTO {
        return try await find(req).toDTO()
    }

    func patch(req: Request) async throws -> Player.DTO {
        let input = try req.content.decode(Player.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.publicId { model.publicId = v }
        if let v = input.displayName { model.displayName = v }
        if let v = input.rank { model.rank = v }
        if let v = input.bio { model.bio = v }
        if let v = input.countryCode { model.countryCode = v }
        if let v = input.avatarUrl { model.avatarUrl = v }
        if let v = input.preferredFormat { model.preferredFormat = v }
        if let v = input.contactEmail { model.contactEmail = v }
        if let v = input.winRateCached { model.winRateCached = v }
        if let v = input.isVerified { model.isVerified = v }
        if let v = input.lastActiveAt { model.lastActiveAt = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func promote(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement promote
        throw Abort(.notImplemented)
    }

    func demote(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement demote
        throw Abort(.notImplemented)
    }

    func recordWin(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement record_win
        return .ok
    }

    func recordLoss(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement record_loss
        return .ok
    }

    func winRate(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement win_rate
        throw Abort(.notImplemented)
    }

    func verify(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement verify
        return .ok
    }

    func updateRating(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let delta = try req.content.get(Int.self, at: "delta")
        // TODO: implement update_rating
        return .ok
    }

}

extension Player.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("countryCode", as: String.self, is: .pattern("[A-Z]{2}"))
    }
}