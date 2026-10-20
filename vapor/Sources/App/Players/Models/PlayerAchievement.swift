import Vapor
import Fluent

final class PlayerAchievement: Model, Content {
    static let schema = "player_achievements"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "earned_at")
    var earnedAt: Date

    @Field(key: "progress")
    var progress: Int

    @Field(key: "is_completed")
    var isCompleted: Bool

    @Parent(key: "player_id")
    var player: Player

    @Parent(key: "achievement_id")
    var achievement: Achievement

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        earnedAt: Date,
        progress: Int = 0,
        isCompleted: Bool = false,
        playerID: UUID,
        achievementID: UUID
    ) {
        self.id = id
        self.earnedAt = earnedAt
        self.progress = progress
        self.isCompleted = isCompleted
        self.$player.id = playerID
        self.$achievement.id = achievementID
    }

    struct DTO: Content {
        var id: UUID?
        var earnedAt: Date
        var progress: Int
        var isCompleted: Bool
        var playerId: UUID?
        var achievementId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            earnedAt: self.earnedAt,
            progress: self.progress,
            isCompleted: self.isCompleted,
            playerId: self.$player.id,
            achievementId: self.$achievement.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension PlayerAchievement {
    struct CreateRequest: Content {
        var earnedAt: Date
        var progress: Int = 0
        var isCompleted: Bool = false
        var playerId: UUID
        var achievementId: UUID
    }

    struct UpdateRequest: Content {
        var earnedAt: Date?
        var progress: Int?
        var isCompleted: Bool?
        var playerId: UUID??
        var achievementId: UUID??
    }
}