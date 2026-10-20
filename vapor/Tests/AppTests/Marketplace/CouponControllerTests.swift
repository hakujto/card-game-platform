@testable import App
import VaporTesting
import Testing

@Suite("CouponController")
struct CouponControllerTests {

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
            try await app.test(.GET, "/api/coupons") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func search() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/coupons?q=test") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "code": "test",
            "discountType": "Percent",
            "discountValue": 0.0,
            "minOrderValue": 0.0,
            "validFrom": "2024-01-01T00:00:00Z",
            "validUntil": "2024-01-01T00:00:00Z",
            "isActive": true
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/coupons",
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