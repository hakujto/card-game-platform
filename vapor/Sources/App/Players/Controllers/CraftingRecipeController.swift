import Vapor
import Fluent

struct CraftingRecipeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "crafting-recipes")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.get(":id", "can-craft", use: canCraft)
        group.post(":id", "craft", use: executeCraft)
        group.post(":id", "disable", use: disable)
        group.post(":id", "enable", use: enable)
    }

    private func find(_ req: Request) async throws -> CraftingRecipe {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await CraftingRecipe.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "CraftingRecipe not found")
        }
        return model
    }

    func index(req: Request) async throws -> [CraftingRecipe.DTO] {
        return try await CraftingRecipe.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(CraftingRecipe.CreateRequest.self)
        let model = CraftingRecipe()
        model.dustCost = input.dustCost
        model.isAvailable = input.isAvailable
        model.$resultCard.id = input.resultCardId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> CraftingRecipe.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> CraftingRecipe.DTO {
        let input = try req.content.decode(CraftingRecipe.CreateRequest.self)
        let model = try await find(req)
        model.dustCost = input.dustCost
        model.isAvailable = input.isAvailable
        model.$resultCard.id = input.resultCardId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> CraftingRecipe.DTO {
        let input = try req.content.decode(CraftingRecipe.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.dustCost { model.dustCost = v }
        if let v = input.isAvailable { model.isAvailable = v }
        if let vv = input.resultCardId, let v = vv { model.$resultCard.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func canCraft(req: Request) async throws -> Response {
        let model = try await find(req)
        let playerId = try req.content.get(Int.self, at: "player_id")
        // TODO: implement can_craft
        throw Abort(.notImplemented)
    }

    func executeCraft(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let playerId = try req.content.get(Int.self, at: "player_id")
        // TODO: implement execute_craft
        return .ok
    }

    func disable(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement disable
        return .ok
    }

    func enable(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement enable
        return .ok
    }

}

extension CraftingRecipe.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}