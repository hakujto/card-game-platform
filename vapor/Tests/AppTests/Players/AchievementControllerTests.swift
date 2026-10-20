@testable import App
import VaporTesting
import Testing

@Suite("AchievementController")
struct AchievementControllerTests {

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
            try await app.test(.GET, "/api/achievements") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func search() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/achievements?q=test") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "name": "test",
            "description": "test",
            "iconUrl": "https://example.com",
            "points": 1,
            "rarity": "Common",
            "isHidden": true
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/achievements",
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

    @Test func update() async throws {
        // TODO: insert fixture, PATCH, verify
        #expect(Bool(true))
    }

}