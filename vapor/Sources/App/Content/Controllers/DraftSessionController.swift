import Vapor
import Fluent

struct DraftSessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "draft-sessions")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "start", use: start)
        group.post(":id", "abandon", use: abandon)
        group.post(":id", "complete", use: complete)
        group.get(":id", "full", use: isFull)
        group.patch(":id", "transitions", "waitingforplayers-to-drafting", use: transitionWaitingForPlayersToDrafting)
        group.patch(":id", "transitions", "drafting-to-completed", use: transitionDraftingToCompleted)
        group.patch(":id", "transitions", "drafting-to-abandoned", use: transitionDraftingToAbandoned)
        group.patch(":id", "transitions", "waitingforplayers-to-abandoned", use: transitionWaitingForPlayersToAbandoned)
    }

    private func find(_ req: Request) async throws -> DraftSession {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await DraftSession.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "DraftSession not found")
        }
        return model
    }

    func index(req: Request) async throws -> [DraftSession.DTO] {
        return try await DraftSession.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(DraftSession.CreateRequest.self)
        let model = DraftSession()
        model.status = input.status
        model.draftType = input.draftType
        model.packContents = input.packContents
        model.seats = input.seats
        model.timePerPickSeconds = input.timePerPickSeconds
        model.completedAt = input.completedAt
        model.$cardSet.id = input.cardSetId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> DraftSession.DTO {
        return try await find(req).toDTO()
    }

    func start(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement start
        return .ok
    }

    func abandon(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement abandon
        return .ok
    }

    func complete(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement complete
        return .ok
    }

    func isFull(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_full
        throw Abort(.notImplemented)
    }

    func transitionWaitingForPlayersToDrafting(req: Request) async throws -> DraftSession.DTO {
        let model = try await find(req)
        // Guard: none
        // TODO: validate transition from WaitingForPlayers to Drafting
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionDraftingToCompleted(req: Request) async throws -> DraftSession.DTO {
        let model = try await find(req)
        // Guard: none
        // TODO: validate transition from Drafting to Completed
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionDraftingToAbandoned(req: Request) async throws -> DraftSession.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Drafting to Abandoned
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionWaitingForPlayersToAbandoned(req: Request) async throws -> DraftSession.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from WaitingForPlayers to Abandoned
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension DraftSession.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}