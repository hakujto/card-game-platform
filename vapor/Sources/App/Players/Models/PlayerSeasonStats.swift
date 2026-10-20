import Vapor
import Fluent

enum PlayerSeasonStatsHighestRank: String, Codable, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    case master = "Master"
    case grandmaster = "Grandmaster"
}

final class PlayerSeasonStats: Model, Content {
    static let schema = "player_season_statss"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "wins")
    var wins: Int

    @Field(key: "losses")
    var losses: Int

    @Field(key: "draws")
    var draws: Int

    @Field(key: "tournament_wins")
    var tournamentWins: Int

    @OptionalField(key: "highest_rank")
    var highestRank: PlayerSeasonStatsHighestRank?

    @Field(key: "season_points")
    var seasonPoints: Int

    @Parent(key: "player_id")
    var player: Player

    @Parent(key: "season_id")
    var season: Season

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        wins: Int = 0,
        losses: Int = 0,
        draws: Int = 0,
        tournamentWins: Int = 0,
        highestRank: PlayerSeasonStatsHighestRank?,
        seasonPoints: Int = 0,
        playerID: UUID,
        seasonID: UUID
    ) {
        self.id = id
        self.wins = wins
        self.losses = losses
        self.draws = draws
        self.tournamentWins = tournamentWins
        self.highestRank = highestRank
        self.seasonPoints = seasonPoints
        self.$player.id = playerID
        self.$season.id = seasonID
    }

    struct DTO: Content {
        var id: UUID?
        var wins: Int
        var losses: Int
        var draws: Int
        var tournamentWins: Int
        var highestRank: PlayerSeasonStatsHighestRank?
        var seasonPoints: Int
        var playerId: UUID?
        var seasonId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            wins: self.wins,
            losses: self.losses,
            draws: self.draws,
            tournamentWins: self.tournamentWins,
            highestRank: self.highestRank,
            seasonPoints: self.seasonPoints,
            playerId: self.$player.id,
            seasonId: self.$season.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension PlayerSeasonStats {
    struct CreateRequest: Content {
        var wins: Int = 0
        var losses: Int = 0
        var draws: Int = 0
        var tournamentWins: Int = 0
        var highestRank: PlayerSeasonStatsHighestRank?
        var seasonPoints: Int = 0
        var playerId: UUID
        var seasonId: UUID
    }

    struct UpdateRequest: Content {
        var wins: Int?
        var losses: Int?
        var draws: Int?
        var tournamentWins: Int?
        var highestRank: PlayerSeasonStatsHighestRank??
        var seasonPoints: Int?
        var playerId: UUID??
        var seasonId: UUID??
    }
}