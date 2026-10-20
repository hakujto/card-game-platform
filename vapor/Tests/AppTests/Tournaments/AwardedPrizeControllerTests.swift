@testable import App
import VaporTesting
import Testing

@Suite("AwardedPrizeController")
struct AwardedPrizeControllerTests {

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
            try await app.test(.GET, "/api/awarded-prizes") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func show() async throws {
        // TODO: insert fixture and test retrieve
        #expect(Bool(true))
    }

}