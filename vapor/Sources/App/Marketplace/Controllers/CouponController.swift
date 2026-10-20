import Vapor
import Fluent

struct CouponController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "coupons")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.get(":id", "valid", use: isValid)
        group.get(":id", "applicable", use: isApplicableToOrder)
        group.post(":id", "redeem", use: redeem)
        group.post(":id", "deactivate", use: deactivate)
    }

    private func find(_ req: Request) async throws -> Coupon {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Coupon.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Coupon not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Coupon.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Coupon.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("code", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Coupon.CreateRequest.validate(content: req)
        let input = try req.content.decode(Coupon.CreateRequest.self)
        let model = Coupon()
        model.code = input.code
        model.discountType = input.discountType
        model.discountValue = input.discountValue
        model.minOrderValue = input.minOrderValue
        model.maxUses = input.maxUses
        model.usesCount = input.usesCount
        model.validFrom = input.validFrom
        model.validUntil = input.validUntil
        model.isActive = input.isActive
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Coupon.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Coupon.DTO {
        let input = try req.content.decode(Coupon.CreateRequest.self)
        let model = try await find(req)
        model.code = input.code
        model.discountType = input.discountType
        model.discountValue = input.discountValue
        model.minOrderValue = input.minOrderValue
        model.maxUses = input.maxUses
        model.usesCount = input.usesCount
        model.validFrom = input.validFrom
        model.validUntil = input.validUntil
        model.isActive = input.isActive
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Coupon.DTO {
        let input = try req.content.decode(Coupon.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.code { model.code = v }
        if let v = input.discountType { model.discountType = v }
        if let v = input.discountValue { model.discountValue = v }
        if let v = input.minOrderValue { model.minOrderValue = v }
        if let v = input.maxUses { model.maxUses = v }
        if let v = input.usesCount { model.usesCount = v }
        if let v = input.validFrom { model.validFrom = v }
        if let v = input.validUntil { model.validUntil = v }
        if let v = input.isActive { model.isActive = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func isValid(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_valid
        throw Abort(.notImplemented)
    }

    func isApplicableToOrder(req: Request) async throws -> Response {
        let model = try await find(req)
        let orderTotal = try req.content.get(Double.self, at: "order_total")
        // TODO: implement is_applicable_to_order
        throw Abort(.notImplemented)
    }

    func redeem(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        guard model.isActive else { throw Abort(.forbidden, reason: "Guard condition not met for redeem") }
        // TODO: implement redeem
        return .ok
    }

    func deactivate(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement deactivate
        return .ok
    }

}

extension Coupon.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("discountValue", as: Double.self, is: .range(0.01...))
    }
}