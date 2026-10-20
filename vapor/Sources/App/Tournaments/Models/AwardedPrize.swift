import Vapor
import Fluent

final class AwardedPrize: Model, Content {
    static let schema = "awarded_prizes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "final_placement")
    var finalPlacement: Int

    @Field(key: "awarded_at")
    var awardedAt: Date

    @Field(key: "claimed")
    var claimed: Bool

    @OptionalField(key: "claimed_at")
    var claimedAt: Date?

    @Parent(key: "prize_id")
    var prize: TournamentPrize

    @Parent(key: "player_id")
    var player: Player

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        finalPlacement: Int,
        awardedAt: Date,
        claimed: Bool = false,
        claimedAt: Date?,
        prizeID: UUID,
        playerID: UUID
    ) {
        self.id = id
        self.finalPlacement = finalPlacement
        self.awardedAt = awardedAt
        self.claimed = claimed
        self.claimedAt = claimedAt
        self.$prize.id = prizeID
        self.$player.id = playerID
    }

    struct DTO: Content {
        var id: UUID?
        var finalPlacement: Int
        var awardedAt: Date
        var claimed: Bool
        var claimedAt: Date?
        var prizeId: UUID?
        var playerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            finalPlacement: self.finalPlacement,
            awardedAt: self.awardedAt,
            claimed: self.claimed,
            claimedAt: self.claimedAt,
            prizeId: self.$prize.id,
            playerId: self.$player.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension AwardedPrize {
    struct CreateRequest: Content {
        var finalPlacement: Int
        var awardedAt: Date
        var claimed: Bool = false
        var claimedAt: Date?
        var prizeId: UUID
        var playerId: UUID
    }

    struct UpdateRequest: Content {
        var claimed: Bool?
        var claimedAt: Date??
        var prizeId: UUID??
        var playerId: UUID??
    }
}