import Vapor
import Fluent

struct TradeTransactionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "trade-transactions")
        group.get(use: index)
        group.get(":id", use: show)
        group.post(":id", "api", "transactions", "{id}", "complete", use: complete)
        group.post(":id", "api", "transactions", "{id}", "refund", use: refund)
        group.post(":id", "api", "transactions", "{id}", "dispute", use: openDispute)
        group.get(":id", "api", "transactions", "{id}", "seller-net", use: sellerNet)
    }

    private func find(_ req: Request) async throws -> TradeTransaction {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TradeTransaction.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TradeTransaction not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TradeTransaction.DTO] {
        return try await TradeTransaction.query(on: req.db).all().map { $0.toDTO() }
    }

    func show(req: Request) async throws -> TradeTransaction.DTO {
        return try await find(req).toDTO()
    }

    func complete(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement complete
        return .ok
    }

    func refund(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement refund
        return .ok
    }

    func openDispute(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let reason = try req.content.get(String.self, at: "reason")
        // TODO: implement open_dispute
        return .ok
    }

    func sellerNet(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement seller_net
        throw Abort(.notImplemented)
    }

}

extension TradeTransaction.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}