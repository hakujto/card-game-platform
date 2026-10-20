import Vapor
import Fluent

struct StreamController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("api", "streams")
        group.get(use: index)
        group.post(use: create)
        group.get(":id", use: show)
        group.put(":id", use: update)
        group.patch(":id", use: patch)
        group.post(":id", "live", use: goLive)
        group.post(":id", "end", use: end)
        group.patch(":id", "viewers", use: updateViewerPeak)
        group.get(":id", "duration", use: durationMinutes)
        group.patch(":id", "transitions", "scheduled-to-live", use: transitionScheduledToLive)
        group.patch(":id", "transitions", "live-to-ended", use: transitionLiveToEnded)
    }

    private func find(_ req: Request) async throws -> Stream {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid id")
        }
        guard let model = try await Stream.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Stream not found")
        }
        return model
    }

    func index(req: Request) async throws -> [Stream.DTO] {
        let q = req.query[String.self, at: "q"]
        let query = Stream.query(on: req.db)
        if let q = q, !q.isEmpty {
            query.group(.or) { $0.filter("title", .custom("LIKE"), "%\(q)%") }
        }
        return try await query.all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> Response {
        let input = try req.content.decode(Stream.CreateRequest.self)
        let model = Stream()
        model.title = input.title
        model.streamUrl = input.streamUrl
        model.status = input.status
        model.platform = input.platform
        model.language = input.language
        model.isOfficial = input.isOfficial
        model.viewerCountPeak = input.viewerCountPeak
        model.scheduledStart = input.scheduledStart
        model.actualStart = input.actualStart
        model.endedAt = input.endedAt
        model.vodUrl = input.vodUrl
        model.$tournament.id = input.tournamentId
        model.$streamer.id = input.streamerId
        try await model.save(on: req.db)
        return Response(status: .created, headers: ["Content-Type": "application/json"], body: .init(data: try JSONEncoder().encode(model.toDTO())))
    }

    func show(req: Request) async throws -> Stream.DTO {
        return try await find(req).toDTO()
    }

    func update(req: Request) async throws -> Stream.DTO {
        let input = try req.content.decode(Stream.CreateRequest.self)
        let model = try await find(req)
        model.title = input.title
        model.streamUrl = input.streamUrl
        model.status = input.status
        model.platform = input.platform
        model.language = input.language
        model.isOfficial = input.isOfficial
        model.viewerCountPeak = input.viewerCountPeak
        model.scheduledStart = input.scheduledStart
        model.actualStart = input.actualStart
        model.endedAt = input.endedAt
        model.vodUrl = input.vodUrl
        model.$tournament.id = input.tournamentId
        model.$streamer.id = input.streamerId
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func patch(req: Request) async throws -> Stream.DTO {
        let input = try req.content.decode(Stream.UpdateRequest.self)
        let model = try await find(req)
        if let v = input.title { model.title = v }
        if let v = input.streamUrl { model.streamUrl = v }
        if let v = input.status { model.status = v }
        if let v = input.platform { model.platform = v }
        if let v = input.language { model.language = v }
        if let v = input.isOfficial { model.isOfficial = v }
        if let v = input.viewerCountPeak { model.viewerCountPeak = v }
        if let v = input.scheduledStart { model.scheduledStart = v }
        if let v = input.actualStart { model.actualStart = v }
        if let v = input.endedAt { model.endedAt = v }
        if let v = input.vodUrl { model.vodUrl = v }
        if let vv = input.tournamentId, let v = vv { model.$tournament.id = v }
        if let vv = input.streamerId, let v = vv { model.$streamer.id = v }
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func goLive(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement go_live
        return .ok
    }

    func end(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        // TODO: implement end
        return .ok
    }

    func updateViewerPeak(req: Request) async throws -> HTTPStatus {
        let model = try await find(req)
        let count = try req.content.get(Int.self, at: "count")
        // TODO: implement update_viewer_peak
        return .ok
    }

    func durationMinutes(req: Request) async throws -> Response {
        let model = try await find(req)
        // TODO: implement duration_minutes
        throw Abort(.notImplemented)
    }

    func transitionScheduledToLive(req: Request) async throws -> Stream.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Scheduled to Live
        try await model.update(on: req.db)
        return model.toDTO()
    }

    func transitionLiveToEnded(req: Request) async throws -> Stream.DTO {
        let model = try await find(req)
        // Guard: [object Object]
        // TODO: validate transition from Live to Ended
        try await model.update(on: req.db)
        return model.toDTO()
    }

}

extension Stream.CreateRequest: Validatable {
    static func validations(_ validations: inout Validations) {
    }
}