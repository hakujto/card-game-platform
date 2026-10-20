import Vapor
import Fluent

struct OrderItemController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "order-items")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
        group.get(":id", "total", use: lineTotal)
    }

    private func find(_ req: Request) async throws -> OrderItem {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await OrderItem.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "OrderItem not found")
        }
        return model
    }

    func index(req: Request) async throws -> [OrderItem.DTO] {
        return try await OrderItem.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(OrderItem.CreateRequest.self)
        let model = OrderItem()
        model.quantity = input.quantity
        model.priceAtPurchase = input.priceAtPurchase
        model.foil = input.foil
        model.$order.id = input.orderId
        model.$product.id = input.productId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> OrderItem.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func lineTotal(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement line_total
        throw Abort(.notImplemented)
    }

}

extension OrderItem.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}