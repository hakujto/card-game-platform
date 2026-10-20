@testable import App
import VaporTesting
import Testing

@Suite("TradeListingController")
struct TradeListingControllerTests {

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
            try await app.test(.GET, "/api/trade-listings") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func search() async throws {
        try await withApp { app in
            try await app.test(.GET, "/api/trade-listings?q=test") { res async in
                #expect(res.status == .ok)
            }
        }
    }

    @Test func create() async throws {
        let body: [String: Any] = [
            "publicId": "00000000-0000-0000-0000-000000000000",
            "status": "Active",
            "listingType": "FixedPrice",
            "askingPrice": 0.0,
            "auctionStartPrice": 0.0,
            "auctionCurrentBid": 0.0,
            "auctionEndTime": "2024-01-01T00:00:00Z",
            "foil": true,
            "condition": "Mint",
            "quantity": 1,
            "description": "test",
            "expiresAt": "2024-01-01T00:00:00Z",
            "sellerId": "00000000-0000-0000-0000-000000000000",
            "cardId": "00000000-0000-0000-0000-000000000000"
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        try await withApp { app in
            try await app.test(.POST, "/api/trade-listings",
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