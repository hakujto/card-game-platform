@testable import App
import VaporTesting
import Testing

@Suite("CardSetController")
struct CardSetControllerTests {

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
            try await app.test(.GET, "/api/card-sets") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func search() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/card-sets?q=test") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "name": "test",
            "code": "test",
            "releaseDate": "2024-01-01",
            "rotationDate": "2024-01-01",
            "setType": "Core",
            "totalCards": 1,
            "isRotated": true,
            "description": "test",
            "logoUrl": "https://example.com"
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/card-sets",
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