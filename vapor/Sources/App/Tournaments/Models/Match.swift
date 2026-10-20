import Vapor
import Fluent

enum MatchStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case active = "Active"
    case completed = "Completed"
    case bYE = "BYE"
    case draw = "Draw"
}

final class Match: Model, Content {
    static let schema = "matchs"

    @ID(key: .id)
    var id: UUID?

    @OptionalField(key: "table_number")
    var tableNumber: Int?

    @Field(key: "status")
    var status: MatchStatus

    @Field(key: "player1_wins")
    var player1Wins: Int

    @Field(key: "player2_wins")
    var player2Wins: Int

    @OptionalField(key: "started_at")
    var startedAt: Date?

    @OptionalField(key: "ended_at")
    var endedAt: Date?

    @OptionalField(key: "result_notes")
    var resultNotes: String?

    @Parent(key: "round_id")
    var round: TournamentRound

    @Parent(key: "player1_id")
    var player1: Player

    @OptionalParent(key: "player2_id")
    var player2: Player?

    @Children(for: \Game.$match)
    var games: [Game]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        tableNumber: Int?,
        status: MatchStatus = .pending,
        player1Wins: Int = 0,
        player2Wins: Int = 0,
        startedAt: Date?,
        endedAt: Date?,
        resultNotes: String?,
        roundID: UUID,
        player1ID: UUID,
        player2ID: UUID? = nil
    ) {
        self.id = id
        self.tableNumber = tableNumber
        self.status = status
        self.player1Wins = player1Wins
        self.player2Wins = player2Wins
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.resultNotes = resultNotes
        self.$round.id = roundID
        self.$player1.id = player1ID
        self.$player2.id = player2ID
    }

    struct DTO: Content {
        var id: UUID?
        var tableNumber: Int?
        var status: MatchStatus
        var player1Wins: Int
        var player2Wins: Int
        var startedAt: Date?
        var endedAt: Date?
        var resultNotes: String?
        var roundId: UUID?
        var player1Id: UUID?
        var player2Id: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            tableNumber: self.tableNumber,
            status: self.status,
            player1Wins: self.player1Wins,
            player2Wins: self.player2Wins,
            startedAt: self.startedAt,
            endedAt: self.endedAt,
            resultNotes: self.resultNotes,
            roundId: self.$round.id,
            player1Id: self.$player1.id,
            player2Id: self.$player2.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Match {
    struct CreateRequest: Content {
        var tableNumber: Int?
        var status: MatchStatus = .pending
        var player1Wins: Int = 0
        var player2Wins: Int = 0
        var startedAt: Date?
        var endedAt: Date?
        var resultNotes: String?
        var roundId: UUID
        var player1Id: UUID
        var player2Id: UUID?
    }

    struct UpdateRequest: Content {
        var tableNumber: Int??
        var status: MatchStatus?
        var player1Wins: Int?
        var player2Wins: Int?
        var startedAt: Date??
        var endedAt: Date??
        var resultNotes: String??
        var roundId: UUID??
        var player1Id: UUID??
        var player2Id: UUID??
    }
}