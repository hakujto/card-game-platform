import Vapor
import Fluent

enum TournamentPrizePrizeType: String, Codable, CaseIterable {
    case currency = "Currency"
    case cards = "Cards"
    case boosterPacks = "BoosterPacks"
    case trophy = "Trophy"
    case seasonPoints = "SeasonPoints"
    case mixed = "Mixed"
}

final class TournamentPrize: Model, Content {
    static let schema = "tournament_prizes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "placement_from")
    var placementFrom: Int

    @Field(key: "placement_to")
    var placementTo: Int

    @Field(key: "prize_type")
    var prizeType: TournamentPrizePrizeType

    @Field(key: "amount")
    var amount: Double

    @OptionalField(key: "description")
    var description: String?

    @OptionalField(key: "packs_count")
    var packsCount: Int?

    @Field(key: "season_points")
    var seasonPoints: Int

    @Parent(key: "tournament_id")
    var tournament: Tournament

    @Children(for: \AwardedPrize.$prize)
    var awardedPrizes: [AwardedPrize]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        placementFrom: Int,
        placementTo: Int,
        prizeType: TournamentPrizePrizeType,
        amount: Double = 0,
        description: String?,
        packsCount: Int?,
        seasonPoints: Int = 0,
        tournamentID: UUID
    ) {
        self.id = id
        self.placementFrom = placementFrom
        self.placementTo = placementTo
        self.prizeType = prizeType
        self.amount = amount
        self.description = description
        self.packsCount = packsCount
        self.seasonPoints = seasonPoints
        self.$tournament.id = tournamentID
    }

    struct DTO: Content {
        var id: UUID?
        var placementFrom: Int
        var placementTo: Int
        var prizeType: TournamentPrizePrizeType
        var amount: Double
        var description: String?
        var packsCount: Int?
        var seasonPoints: Int
        var tournamentId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            placementFrom: self.placementFrom,
            placementTo: self.placementTo,
            prizeType: self.prizeType,
            amount: self.amount,
            description: self.description,
            packsCount: self.packsCount,
            seasonPoints: self.seasonPoints,
            tournamentId: self.$tournament.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TournamentPrize {
    struct CreateRequest: Content {
        var placementFrom: Int
        var placementTo: Int
        var prizeType: TournamentPrizePrizeType
        var amount: Double = 0
        var description: String?
        var packsCount: Int?
        var seasonPoints: Int = 0
        var tournamentId: UUID
    }

    struct UpdateRequest: Content {
        var placementFrom: Int?
        var placementTo: Int?
        var prizeType: TournamentPrizePrizeType?
        var amount: Double?
        var description: String??
        var packsCount: Int??
        var seasonPoints: Int?
        var tournamentId: UUID??
    }
}