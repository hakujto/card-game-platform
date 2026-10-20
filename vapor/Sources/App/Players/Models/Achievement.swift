import Vapor
import Fluent

enum AchievementRarity: String, Codable, CaseIterable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
}

final class Achievement: Model, Content {
    static let schema = "achievements"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @OptionalField(key: "icon_url")
    var iconUrl: String?

    @Field(key: "points")
    var points: Int

    @Field(key: "rarity")
    var rarity: AchievementRarity

    @Field(key: "is_hidden")
    var isHidden: Bool

    @Children(for: \PlayerAchievement.$achievement)
    var playerRecords: [PlayerAchievement]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        description: String,
        iconUrl: String?,
        points: Int = 10,
        rarity: AchievementRarity = .common,
        isHidden: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.iconUrl = iconUrl
        self.points = points
        self.rarity = rarity
        self.isHidden = isHidden
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var description: String
        var iconUrl: String?
        var points: Int
        var rarity: AchievementRarity
        var isHidden: Bool
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            description: self.description,
            iconUrl: self.iconUrl,
            points: self.points,
            rarity: self.rarity,
            isHidden: self.isHidden,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Achievement {
    struct CreateRequest: Content {
        var name: String
        var description: String
        var iconUrl: String?
        var points: Int = 10
        var rarity: AchievementRarity = .common
        var isHidden: Bool = false
    }

    struct UpdateRequest: Content {
        var name: String?
        var description: String?
        var iconUrl: String??
        var points: Int?
        var rarity: AchievementRarity?
        var isHidden: Bool?
    }
}