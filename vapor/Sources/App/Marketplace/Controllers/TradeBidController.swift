import Vapor
import Fluent

struct TradeBidController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "trade-bids")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.get(":id", "api", "bids", "{id}", "outbid", use: outbidBy)
        group.delete(":id", "api", "bids", "{id}", use: retract)
    }

    private func find(_ req: Request) async throws -> TradeBid {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TradeBid.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TradeBid not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TradeBid.DTO] {
        return try await TradeBid.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(TradeBid.CreateRequest.self)
        let model = TradeBid()
        model.amount = input.amount
        model.placedAt = input.placedAt
        model.isWinning = input.isWinning
        model.$listing.id = input.listingId
        model.$bidder.id = input.bidderId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TradeBid.DTO {
        return try await find(req).toDTO()
    }

    func outbidBy(req: Request) async throws -> Response {
        let model = try await find(req)
        let newAmount = try req.content.get(Double.self, at: "new_amount")
        // TODO: implement outbid_by
        throw Abort(.notImplemented)
    }

    func retract(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement retract
        return .ok
    }

}

extension TradeBid.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}