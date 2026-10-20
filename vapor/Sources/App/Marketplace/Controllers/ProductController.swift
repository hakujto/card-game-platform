import Vapor
import Fluent

struct ProductController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "products")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.post(":id", "activate", use: activate)
        group.post(":id", "deactivate", use: deactivate)
        group.patch(":id", "discount", use: applyDiscount)
        group.post(":id", "restock", use: restock)
        group.get(":id", "effective-price", use: effectivePrice)
        group.get(":id", "in-stock", use: isInStock)
    }

    private func find(_ req: Request) async throws -> Product {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Product.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Product not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Product.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Product.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
            query.group(.or) { $0.filter("description", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        try Product.CreateRequest.validate(content: req)
        let input = try req.content.decode(Product.CreateRequest.self)
        let model = Product()
        model.name = input.name
        model.productType = input.productType
        model.price = input.price
        model.stock = input.stock
        model.active = input.active
        model.discountPercent = input.discountPercent
        model.description = input.description
        model.imageUrl = input.imageUrl
        model.featured = input.featured
        model.$card.id = input.cardId
        model.$cardSet.id = input.cardSetId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Product.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Product.DTO {
        let input = try req.content.decode(Product.CreateRequest.self)
        let model = try await find(req)
        model.name = input.name
        model.productType = input.productType
        model.price = input.price
        model.stock = input.stock
        model.active = input.active
        model.discountPercent = input.discountPercent
        model.description = input.description
        model.imageUrl = input.imageUrl
        model.featured = input.featured
        model.$card.id = input.cardId
        model.$cardSet.id = input.cardSetId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Product.DTO {
        let input = try req.content.decode(Product.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.name { model.name = v }
        if let v = input.productType { model.productType = v }
        if let v = input.price { model.price = v }
        if let v = input.stock { model.stock = v }
        if let v = input.active { model.active = v }
        if let v = input.discountPercent { model.discountPercent = v }
        if let v = input.description { model.description = v }
        if let v = input.imageUrl { model.imageUrl = v }
        if let v = input.featured { model.featured = v }
        if let vv = input.cardId, let v = vv { model.$card.id = v }
        if let vv = input.cardSetId, let v = vv { model.$cardSet.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func activate(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement activate
        return .ok
    }

    func deactivate(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement deactivate
        return .ok
    }

    func applyDiscount(req: Request) async throws -> Response {
        let model = try await find(req)
        let percent = try req.content.get(Int.self, at: "percent")
        // TODO: implement apply_discount
        throw Abort(.notImplemented)
    }

    func restock(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let quantity = try req.content.get(Int.self, at: "quantity")
        // TODO: implement restock
        return .ok
    }

    func effectivePrice(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement effective_price
        throw Abort(.notImplemented)
    }

    func isInStock(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_in_stock
        throw Abort(.notImplemented)
    }

}

extension Product.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("discountPercent", as: Int.self, is: .range(0...))
        validations.add("discountPercent", as: Int.self, is: .range(...100))
    }
}