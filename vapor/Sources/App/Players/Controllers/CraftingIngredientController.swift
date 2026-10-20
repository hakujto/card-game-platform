import Vapor
import Fluent

struct CraftingIngredientController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "crafting-ingredients")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
    }

    private func find(_ req: Request) async throws -> CraftingIngredient {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await CraftingIngredient.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "CraftingIngredient not found")
        }
        return model
    }

    func index(req: Request) async throws -> [CraftingIngredient.DTO] {
        return try await CraftingIngredient.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CraftingIngredient.CreateRequest.self)
        let model = CraftingIngredient()
        model.quantity = input.quantity
        model.$recipe.id = input.recipeId
        model.$card.id = input.cardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> CraftingIngredient.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

}