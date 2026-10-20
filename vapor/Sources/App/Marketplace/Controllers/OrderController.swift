import Vapor
import Fluent

struct OrderController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "orders")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", "cancel", use: cancel)
        group.post(":id", "pay", use: pay)
        group.post(":id", "process-payment", use: processPayment)
        group.get(":id", "total", use: calculateTotal)
        group.patch(":id", "discount", use: applyDiscount)
        group.post(":id", "refund", use: refund)
        group.patch(":id", "transitions", "pending-to-paid", use: transitionPendingToPaid)
        group.patch(":id", "transitions", "paid-to-processing", use: transitionPaidToProcessing)
        group.patch(":id", "transitions", "processing-to-shipped", use: transitionProcessingToShipped)
        group.patch(":id", "transitions", "shipped-to-completed", use: transitionShippedToCompleted)
        group.patch(":id", "transitions", "pending-to-cancelled", use: transitionPendingToCancelled)
        group.patch(":id", "transitions", "paid-to-cancelled", use: transitionPaidToCancelled)
        group.patch(":id", "transitions", "completed-to-refunded", use: transitionCompletedToRefunded)
    }

    private func find(_ req: Request) async throws -> Order {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Order.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Order not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Order.DTO] {
        return try await Order.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Order.CreateRequest.validate(content: req)
        let input = try req.content.decode(Order.CreateRequest.self)
        if input.status == .shipped && input.trackingNumber == nil { throw Abort(.badRequest, reason: "trackingNumber is required") }
        if input.status == .paid && input.paidAt == nil { throw Abort(.badRequest, reason: "paidAt is required") }
        let model = Order()
        model.status = input.status
        model.total = input.total
        model.discountApplied = input.discountApplied
        model.currency = input.currency
        model.paymentMethod = input.paymentMethod
        model.paymentReference = input.paymentReference
        model.shippingAddress = input.shippingAddress
        model.trackingNumber = input.trackingNumber
        model.paidAt = input.paidAt
        model.shippedAt = input.shippedAt
        model.$player.id = input.playerId
        model.$coupon.id = input.couponId
        try await model.save(on: req.db)
        // TODO: audit log — track create
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Order.DTO {
        return try await find(req).toDTO()
    }

    func cancel(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement cancel
        return .ok
    }

    func pay(req: Request) async throws -> Response {
        let model = try await find(req)
        guard model.status == .pending else { throw Abort(.forbidden, reason: "Guard condition not met for pay") }
        let paymentRef = try req.content.get(String.self, at: "payment_ref")
        // TODO: implement pay
        throw Abort(.notImplemented)
    }

    func processPayment(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement process_payment
        throw Abort(.notImplemented)
    }

    func calculateTotal(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement calculate_total
        throw Abort(.notImplemented)
    }

    func applyDiscount(req: Request) async throws -> Response {
        let model = try await find(req)
        let percent = try req.content.get(Int.self, at: "percent")
        // TODO: implement apply_discount
        throw Abort(.notImplemented)
    }

    func refund(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement refund
        return .ok
    }

    func transitionPendingToPaid(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: none
        // TODO: validate transition from Pending to Paid
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionPaidToProcessing(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Paid to Processing
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionProcessingToShipped(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Processing to Shipped
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionShippedToCompleted(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Shipped to Completed
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionPendingToCancelled(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: none
        // TODO: validate transition from Pending to Cancelled
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionPaidToCancelled(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Paid to Cancelled
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionCompletedToRefunded(req: Request) async throws -> Order.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Completed to Refunded
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension Order.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("currency", as: String.self, is: .pattern("[A-Z]{3}"))
    }
}