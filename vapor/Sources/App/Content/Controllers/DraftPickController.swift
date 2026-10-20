import Vapor
import Fluent

struct DraftPickController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "draft-picks")
        group.get(use: index)
        group.get(":id", use: show)
        group.get(":id", "first-pick", use: isFirstPick)
    }

    private func find(_ req: Request) async throws -> DraftPick {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await DraftPick.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "DraftPick not found")
        }
        return model
    }

    func index(req: Request) async throws -> [DraftPick.DTO] {
        return try await DraftPick.query(on: req.db).all().map { $0.toDTO() }
    }

    func show(req: Request) async throws -> DraftPick.DTO {
        return try await find(req).toDTO()
    }

    func isFirstPick(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement is_first_pick
        throw Abort(.notImplemented)
    }

}

extension DraftPick.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}