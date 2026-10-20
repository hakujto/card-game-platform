import Vapor
import Fluent

enum GameWinnerSide: String, Codable, CaseIterable {
    case player1 = "Player1"
    case player2 = "Player2"
    case draw = "Draw"
}

enum GameEndedBy: String, Codable, CaseIterable {
    case normal = "Normal"
    case timeout = "Timeout"
    case concession = "Concession"
    case drawOffer = "DrawOffer"
}

final class Game: Model, Content {
    static let schema = "games"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "game_number")
    var gameNumber: Int

    @OptionalField(key: "winner_side")
    var winnerSide: GameWinnerSide?

    @OptionalField(key: "complexity_score")
    var complexityScore: Double?

    @OptionalField(key: "turns_played")
    var turnsPlayed: Int?

    @OptionalField(key: "duration_seconds")
    var durationSeconds: Int?

    @OptionalField(key: "ended_by")
    var endedBy: GameEndedBy?

    @OptionalField(key: "replay_url")
    var replayUrl: String?

    @Parent(key: "match_id")
    var match: Match

    @OptionalParent(key: "winner_id")
    var winner: Player?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        gameNumber: Int,
        winnerSide: GameWinnerSide?,
        complexityScore: Double?,
        turnsPlayed: Int?,
        durationSeconds: Int?,
        endedBy: GameEndedBy?,
        replayUrl: String?,
        matchID: UUID,
        winnerID: UUID? = nil
    ) {
        self.id = id
        self.gameNumber = gameNumber
        self.winnerSide = winnerSide
        self.complexityScore = complexityScore
        self.turnsPlayed = turnsPlayed
        self.durationSeconds = durationSeconds
        self.endedBy = endedBy
        self.replayUrl = replayUrl
        self.$match.id = matchID
        self.$winner.id = winnerID
    }

    struct DTO: Content {
        var id: UUID?
        var gameNumber: Int
        var winnerSide: GameWinnerSide?
        var complexityScore: Double?
        var turnsPlayed: Int?
        var durationSeconds: Int?
        var endedBy: GameEndedBy?
        var replayUrl: String?
        var matchId: UUID?
        var winnerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            gameNumber: self.gameNumber,
            winnerSide: self.winnerSide,
            complexityScore: self.complexityScore,
            turnsPlayed: self.turnsPlayed,
            durationSeconds: self.durationSeconds,
            endedBy: self.endedBy,
            replayUrl: self.replayUrl,
            matchId: self.$match.id,
            winnerId: self.$winner.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Game {
    struct CreateRequest: Content {
        var gameNumber: Int
        var winnerSide: GameWinnerSide?
        var complexityScore: Double?
        var turnsPlayed: Int?
        var durationSeconds: Int?
        var endedBy: GameEndedBy?
        var replayUrl: String?
        var matchId: UUID
        var winnerId: UUID?
    }

    struct UpdateRequest: Content {
        var gameNumber: Int?
        var winnerSide: GameWinnerSide??
        var complexityScore: Double??
        var turnsPlayed: Int??
        var durationSeconds: Int??
        var endedBy: GameEndedBy??
        var replayUrl: String??
        var matchId: UUID??
        var winnerId: UUID??
    }
}