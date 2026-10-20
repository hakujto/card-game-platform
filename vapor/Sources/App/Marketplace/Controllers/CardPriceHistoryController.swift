import Vapor
import Fluent

struct CardPriceHistoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "card-price-histories")
        group.get(use: index)
        group.get(":id", use: show)
        group.get(":id", "api", "price-history", "{id}", "change", use: priceChangePercent)
        group.get(":id", "api", "price-history", "{id}", "spike", use: isPriceSpike)
    }

    private func find(_ req: Request) async throws -> CardPriceHistory {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await CardPriceHistory.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "CardPriceHistory not found")
        }
        return model
    }

    func index(req: Request) async throws -> [CardPriceHistory.DTO] {
        return try await CardPriceHistory.query(on: req.db).all().map { $0.toDTO() }
    }

    func show(req: Request) async throws -> CardPriceHistory.DTO {
        return try await find(req).toDTO()
    }

    func priceChangePercent(req: Request) async throws -> Response {
        let model = try await find(req)
        let previousAvg = try req.content.get(Double.self, at: "previous_avg")
        // TODO: implement price_change_percent
        throw Abort(.notImplemented)
    }

    func isPriceSpike(req: Request) async throws -> Response {
        let model = try await find(req)
        let thresholdPercent = try req.content.get(Int.self, at: "threshold_percent")
        // TODO: implement is_price_spike
        throw Abort(.notImplemented)
    }

}

extension CardPriceHistory.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}