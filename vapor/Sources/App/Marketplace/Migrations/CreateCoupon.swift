import Fluent

struct CreateCoupon: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("coupons")
            .id()
            .field("code", .string, .required)
            .field("discount_type", .string, .required, .sql(.default("Percent")))
            .field("discount_value", .double, .required)
            .field("min_order_value", .double, .required, .sql(.default(0)))
            .field("max_uses", .int)
            .field("uses_count", .int, .required, .sql(.default(0)))
            .field("valid_from", .datetime, .required)
            .field("valid_until", .datetime, .required)
            .field("is_active", .bool, .required, .sql(.default(true)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "code")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("coupons").delete()
    }
}