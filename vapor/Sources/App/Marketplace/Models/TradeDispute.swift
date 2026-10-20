import Vapor
import Fluent

enum TradeDisputeStatus: String, Codable, CaseIterable {
    case `open` = "Open"
    case underReview = "UnderReview"
    case resolved = "Resolved"
    case escalated = "Escalated"
}

enum TradeDisputeReason: String, Codable, CaseIterable {
    case itemNotReceived = "ItemNotReceived"
    case itemNotAsDescribed = "ItemNotAsDescribed"
    case fraudSuspected = "FraudSuspected"
    case other = "Other"
}

final class TradeDispute: Model, Content {
    static let schema = "trade_disputes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: TradeDisputeStatus

    @Field(key: "reason")
    var reason: TradeDisputeReason

    @Field(key: "description")
    var description: String

    @OptionalField(key: "resolution")
    var resolution: String?

    @Field(key: "opened_at")
    var openedAt: Date

    @OptionalField(key: "resolved_at")
    var resolvedAt: Date?

    @Parent(key: "transaction_id")
    var transaction: TradeTransaction

    @Parent(key: "opened_by_id")
    var openedBy: Player

    @OptionalParent(key: "resolved_by_id")
    var resolvedBy: Player?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        status: TradeDisputeStatus = .open,
        reason: TradeDisputeReason,
        description: String,
        resolution: String?,
        openedAt: Date,
        resolvedAt: Date?,
        transactionID: UUID,
        openedByID: UUID,
        resolvedByID: UUID? = nil
    ) {
        self.id = id
        self.status = status
        self.reason = reason
        self.description = description
        self.resolution = resolution
        self.openedAt = openedAt
        self.resolvedAt = resolvedAt
        self.$transaction.id = transactionID
        self.$openedBy.id = openedByID
        self.$resolvedBy.id = resolvedByID
    }

    struct DTO: Content {
        var id: UUID?
        var status: TradeDisputeStatus
        var reason: TradeDisputeReason
        var description: String
        var resolution: String?
        var openedAt: Date
        var resolvedAt: Date?
        var transactionId: UUID?
        var openedById: UUID?
        var resolvedById: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            status: self.status,
            reason: self.reason,
            description: self.description,
            resolution: self.resolution,
            openedAt: self.openedAt,
            resolvedAt: self.resolvedAt,
            transactionId: self.$transaction.id,
            openedById: self.$openedBy.id,
            resolvedById: self.$resolvedBy.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TradeDispute {
    struct CreateRequest: Content {
        var status: TradeDisputeStatus = .open
        var reason: TradeDisputeReason
        var description: String
        var resolution: String?
        var openedAt: Date
        var resolvedAt: Date?
        var transactionId: UUID
        var openedById: UUID
        var resolvedById: UUID?
    }

    struct UpdateRequest: Content {
        var status: TradeDisputeStatus?
        var reason: TradeDisputeReason?
        var description: String?
        var resolution: String??
        var openedAt: Date?
        var resolvedAt: Date??
        var transactionId: UUID??
        var openedById: UUID??
        var resolvedById: UUID??
    }
}