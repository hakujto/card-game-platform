import Vapor
import Fluent

struct DeckTagController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "deck-tags")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.patch(":id", use: patch)
        group.delete(":id", use: delete)
        group.patch(":id", "rename", use: rename)
        group.post(":id", "merge", use: mergeInto)
    }

    private func find(_ req: Request) async throws -> DeckTag {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await DeckTag.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "DeckTag not found")
        }
        return model
    }

    func index(req: Request) async throws -> [DeckTag.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = DeckTag.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("name", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(DeckTag.CreateRequest.self)
        let model = DeckTag()
        model.name = input.name
        model.slug = input.slug
        model.color = input.color
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> DeckTag.DTO {
        return try await find(req).toDTO()
    }

    func patch(req: Request) async throws -> DeckTag.DTO {
        let input = try req.content.decode(DeckTag.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.name { model.name = v }
        if let v = input.slug { model.slug = v }
        if let v = input.color { model.color = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        try await (try await find(req)).delete(on: req.db)
        return .noContent
    }

    func rename(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let newName = try req.content.get(String.self, at: "new_name")
        // TODO: implement rename
        return .ok
    }

    func mergeInto(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let targetTagId = try req.content.get(Int.self, at: "target_tag_id")
        // TODO: implement merge_into
        return .ok
    }

}