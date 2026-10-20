import Vapor
import Fluent

struct TradeDisputeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "trade-disputes")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.post(":id", "api", "disputes", "{id}", "escalate", use: escalate)
        group.post(":id", "api", "disputes", "{id}", "resolve", use: resolve)
        group.post(":id", "api", "disputes", "{id}", "close", use: closeResolved)
        group.post(":id", "api", "disputes", "{id}", "review", use: review)
        group.patch(":id", "transitions", "open-to-underreview", use: transitionOpenToUnderReview)
        group.patch(":id", "transitions", "underreview-to-resolved", use: transitionUnderReviewToResolved)
        group.patch(":id", "transitions", "underreview-to-escalated", use: transitionUnderReviewToEscalated)
        group.patch(":id", "transitions", "escalated-to-resolved", use: transitionEscalatedToResolved)
    }

    private func find(_ req: Request) async throws -> TradeDispute {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TradeDispute.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TradeDispute not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TradeDispute.DTO] {
        return try await TradeDispute.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(TradeDispute.CreateRequest.self)
        let model = TradeDispute()
        model.status = input.status
        model.reason = input.reason
        model.description = input.description
        model.resolution = input.resolution
        model.openedAt = input.openedAt
        model.resolvedAt = input.resolvedAt
        model.$transaction.id = input.transactionId
        model.$openedBy.id = input.openedById
        model.$resolvedBy.id = input.resolvedById
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TradeDispute.DTO {
        return try await find(req).toDTO()
    }

    func escalate(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement escalate
        return .ok
    }

    func resolve(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let resolutionText = try req.content.get(String.self, at: "resolution_text")
        // TODO: implement resolve
        return .ok
    }

    func closeResolved(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement close_resolved
        return .ok
    }

    func review(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement review
        return .ok
    }

    func transitionOpenToUnderReview(req: Request) async throws -> TradeDispute.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Open to UnderReview
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionUnderReviewToResolved(req: Request) async throws -> TradeDispute.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from UnderReview to Resolved
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionUnderReviewToEscalated(req: Request) async throws -> TradeDispute.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from UnderReview to Escalated
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionEscalatedToResolved(req: Request) async throws -> TradeDispute.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Escalated to Resolved
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension TradeDispute.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}