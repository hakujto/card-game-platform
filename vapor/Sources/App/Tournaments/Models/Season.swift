import Vapor
import Fluent

enum SeasonFormat: String, Codable, CaseIterable {
    case standard = "Standard"
    case extended = "Extended"
    case legacy = "Legacy"
    case vintage = "Vintage"
    case commander = "Commander"
    case draft = "Draft"
}

final class Season: Model, Content {
    static let schema = "seasons"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "start_date")
    var startDate: String

    @Field(key: "end_date")
    var endDate: String

    @Field(key: "format")
    var format: SeasonFormat

    @Field(key: "is_active")
    var isActive: Bool

    @OptionalField(key: "reward_description")
    var rewardDescription: String?

    @Children(for: \PlayerSeasonStats.$season)
    var playerStats: [PlayerSeasonStats]

    @Children(for: \Tournament.$season)
    var tournaments: [Tournament]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        startDate: String,
        endDate: String,
        format: SeasonFormat = .standard,
        isActive: Bool = false,
        rewardDescription: String?
    ) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.format = format
        self.isActive = isActive
        self.rewardDescription = rewardDescription
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var startDate: String
        var endDate: String
        var format: SeasonFormat
        var isActive: Bool
        var rewardDescription: String?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            startDate: self.startDate,
            endDate: self.endDate,
            format: self.format,
            isActive: self.isActive,
            rewardDescription: self.rewardDescription,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Season {
    struct CreateRequest: Content {
        var name: String
        var startDate: String
        var endDate: String
        var format: SeasonFormat = .standard
        var isActive: Bool = false
        var rewardDescription: String?
    }

    struct UpdateRequest: Content {
        var name: String?
        var startDate: String?
        var endDate: String?
        var format: SeasonFormat?
        var isActive: Bool?
        var rewardDescription: String??
    }
}