import Vapor
import Fluent

struct DraftParticipantController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "draft-participants")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "pick", use: pickCard)
        group.get(":id", "card-count", use: draftedCardCount)
    }

    private func find(_ req: Request) async throws -> DraftParticipant {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await DraftParticipant.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "DraftParticipant not found")
        }
        return model
    }

    func index(req: Request) async throws -> [DraftParticipant.DTO] {
        return try await DraftParticipant.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(DraftParticipant.CreateRequest.self)
        let model = DraftParticipant()
        model.seatNumber = input.seatNumber
        model.joinedAt = input.joinedAt
        model.$session.id = input.sessionId
        model.$player.id = input.playerId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> DraftParticipant.DTO {
        return try await find(req).toDTO()
    }

    func pickCard(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let cardId = try req.content.get(Int.self, at: "card_id")
        let packNumber = try req.content.get(Int.self, at: "pack_number")
        // TODO: implement pick_card
        return .ok
    }

    func draftedCardCount(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement drafted_card_count
        throw Abort(.notImplemented)
    }

}

extension DraftParticipant.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}