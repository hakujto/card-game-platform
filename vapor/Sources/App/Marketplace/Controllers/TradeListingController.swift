import Vapor
import Fluent

struct TradeListingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "trade-listings")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.patch(":id", use: patch)
        group.post(":id", "close", use: close)
        group.patch(":id", "extend", use: extend)
        group.delete(":id", "cancel", use: cancel)
        group.get(":id", "expired", use: isExpired)
        group.post(":id", "finalize", use: finalizeAuction)
        group.patch(":id", "transitions", "pending-to-active", use: transitionPendingToActive)
        group.patch(":id", "transitions", "active-to-sold", use: transitionActiveToSold)
        group.patch(":id", "transitions", "active-to-expired", use: transitionActiveToExpired)
        group.patch(":id", "transitions", "active-to-cancelled", use: transitionActiveToCancelled)
    }

    private func find(_ req: Request) async throws -> TradeListing {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await TradeListing.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "TradeListing not found")
        }
        return model
    }

    func index(req: Request) async throws -> [TradeListing.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = TradeListing.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("description", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(TradeListing.CreateRequest.self)
        if input.listingType == .fixedPrice && input.askingPrice == nil { throw Abort(.badRequest, reason: "askingPrice is required") }
        let model = TradeListing()
        model.publicId = input.publicId
        model.status = input.status
        model.listingType = input.listingType
        model.askingPrice = input.askingPrice
        model.auctionStartPrice = input.auctionStartPrice
        model.auctionCurrentBid = input.auctionCurrentBid
        model.auctionEndTime = input.auctionEndTime
        model.foil = input.foil
        model.condition = input.condition
        model.quantity = input.quantity
        model.description = input.description
        model.expiresAt = input.expiresAt
        model.$seller.id = input.sellerId
        model.$card.id = input.cardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> TradeListing.DTO {
        return try await find(req).toDTO()
    }

    func patch(req: Request) async throws -> TradeListing.DTO {
        let input = try req.content.decode(TradeListing.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.publicId { model.publicId = v }
        if let v = input.listingType { model.listingType = v }
        if let v = input.askingPrice { model.askingPrice = v }
        if let v = input.auctionStartPrice { model.auctionStartPrice = v }
        if let v = input.auctionCurrentBid { model.auctionCurrentBid = v }
        if let v = input.auctionEndTime { model.auctionEndTime = v }
        if let v = input.foil { model.foil = v }
        if let v = input.condition { model.condition = v }
        if let v = input.quantity { model.quantity = v }
        if let v = input.description { model.description = v }
        if let v = input.expiresAt { model.expiresAt = v }
        if let vv = input.sellerId, let v = vv { model.$seller.id = v }
        if let vv = input.cardId, let v = vv { model.$card.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func close(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement close
        return .ok
    }

    func extend(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let days = try req.content.get(Int.self, at: "days")
        // TODO: implement extend
        return .ok
    }

    func cancel(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        guard model.status == .active else { throw Abort(.forbidden, reason: "Guard condition not met for cancel") }
        // TODO: implement cancel
        return .ok
    }

    func isExpired(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_expired
        throw Abort(.notImplemented)
    }

    func finalizeAuction(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement finalize_auction
        return .ok
    }

    func transitionPendingToActive(req: Request) async throws -> TradeListing.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Pending to Active
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionActiveToSold(req: Request) async throws -> TradeListing.DTO {
        let model = try await find(req)
        // Guard: none
        // TODO: validate transition from Active to Sold
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionActiveToExpired(req: Request) async throws -> TradeListing.DTO {
        let model = try await find(req)
        // Guard: none
        // TODO: validate transition from Active to Expired
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionActiveToCancelled(req: Request) async throws -> TradeListing.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Active to Cancelled
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension TradeListing.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}