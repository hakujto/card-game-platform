@testable import App
import VaporTesting
import Testing

@Suite("DeckTagAssignmentController")
struct DeckTagAssignmentControllerTests {

    func withApp<T>(_ body: (Application) async throws -> T) async throws -> T {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            let result = try await body(app)
            try await app.asyncShutdown()
            return result
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }

    @Test func list() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/deck-tag-assignments") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "deckId": "00000000-0000-0000-0000-000000000000",
            "tagId": "00000000-0000-0000-0000-000000000000"
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/deck-tag-assignments",
                beforeRequest: { req in
                    req.headers.contentType = .json
                    req.body = .init(data: data)
                }, afterResponse: { res async in
                    #expect(res.status != .notFound && res.status != .methodNotAllowed)
                }
            )
        }
    }

    @Test func show() async throws {
        // TODO: insert fixture and test retrieve
        #expect(Bool(true))
    }

    @Test func delete() async throws {
        // TODO: insert fixture, DELETE, verify 204
        #expect(Bool(true))
    }

}