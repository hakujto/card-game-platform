@testable import App
import VaporTesting
import Testing

@Suite("CardController")
struct CardControllerTests {

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
            try await app.test(.GET, "/api/cards") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func search() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/cards?q=test") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "publicId": "00000000-0000-0000-0000-000000000000",
            "name": "test",
            "cardType": "Creature",
            "rarity": "Common",
            "manaCost": 1,
            "manaColors": "White",
            "attack": 1,
            "defense": 1,
            "loyalty": 1,
            "description": "test",
            "flavorText": "test",
            "imageUrl": "https://example.com",
            "artistName": "test",
            "legalFormats": "Standard",
            "isBanned": true,
            "isRestricted": true,
            "powerLevel": 1,
            "metadata": "{}",
            "totalCopiesInCirculation": 1,
            "setId": "00000000-0000-0000-0000-000000000000"
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/cards",
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