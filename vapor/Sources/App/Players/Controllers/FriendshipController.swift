import Vapor
import Fluent

struct FriendshipController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "friendships")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.delete(":id", use: delete)
        group.post(":id", "accept", use: accept)
        group.post(":id", "decline", use: decline)
        group.post(":id", "block", use: block)
    }

    private func find(_ req: Request) async throws -> Friendship {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Friendship.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Friendship not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Friendship.DTO] {
        return try await Friendship.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Friendship.CreateRequest.self)
        let model = Friendship()
        model.status = input.status
        model.$requester.id = input.requesterId
        model.$receiver.id = input.receiverId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Friendship.DTO {
        return try await find(req).toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func accept(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement accept
        return .ok
    }

    func decline(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement decline
        return .ok
    }

    func block(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement block
        return .ok
    }

}