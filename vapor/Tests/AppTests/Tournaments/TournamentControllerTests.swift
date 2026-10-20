@testable import App
import VaporTesting
import Testing

@Suite("TournamentController")
struct TournamentControllerTests {

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
            try await app.test(.GET, "/api/tournaments") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func search() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/tournaments?q=test") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "publicId": "00000000-0000-0000-0000-000000000000",
            "name": "test",
            "description": "test",
            "status": "Draft",
            "bracketData": "{}",
            "format": "Standard",
            "tournamentType": "Swiss",
            "maxPlayers": 1,
            "entryFee": 0.0,
            "prizePool": 0.0,
            "startTime": "2024-01-01T00:00:00Z",
            "endTime": "2024-01-01T00:00:00Z",
            "isOnline": true,
            "location": "test",
            "rulesText": "test",
            "seasonId": "00000000-0000-0000-0000-000000000000",
            "organizerId": "00000000-0000-0000-0000-000000000000"
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/tournaments",
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