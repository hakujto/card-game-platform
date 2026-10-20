import Vapor
import Fluent

struct AwardedPrizeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "awarded-prizes")
        group.get(use: index)
        group.get(":id", use: show)
        group.post(":id", "claim", use: claim)
    }

    private func find(_ req: Request) async throws -> AwardedPrize {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await AwardedPrize.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "AwardedPrize not found")
        }
        return model
    }

    func index(req: Request) async throws -> [AwardedPrize.DTO] {
        return try await AwardedPrize.query(on: req.db).all().map { $0.toDTO() }
    }

    func show(req: Request) async throws -> AwardedPrize.DTO {
        return try await find(req).toDTO()
    }

    func claim(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement claim
        return .ok
    }

}

extension AwardedPrize.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}