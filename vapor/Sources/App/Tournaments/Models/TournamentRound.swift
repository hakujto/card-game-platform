import Vapor
import Fluent

enum TournamentRoundStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case active = "Active"
    case completed = "Completed"
}

final class TournamentRound: Model, Content {
    static let schema = "tournament_rounds"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "round_number")
    var roundNumber: Int

    @Field(key: "status")
    var status: TournamentRoundStatus

    @OptionalField(key: "started_at")
    var startedAt: Date?

    @OptionalField(key: "ended_at")
    var endedAt: Date?

    @Field(key: "time_limit_minutes")
    var timeLimitMinutes: Int

    @Parent(key: "tournament_id")
    var tournament: Tournament

    @Children(for: \Match.$round)
    var matches: [Match]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        roundNumber: Int,
        status: TournamentRoundStatus = .pending,
        startedAt: Date?,
        endedAt: Date?,
        timeLimitMinutes: Int = 50,
        tournamentID: UUID
    ) {
        self.id = id
        self.roundNumber = roundNumber
        self.status = status
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.timeLimitMinutes = timeLimitMinutes
        self.$tournament.id = tournamentID
    }

    struct DTO: Content {
        var id: UUID?
        var roundNumber: Int
        var status: TournamentRoundStatus
        var startedAt: Date?
        var endedAt: Date?
        var timeLimitMinutes: Int
        var tournamentId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            roundNumber: self.roundNumber,
            status: self.status,
            startedAt: self.startedAt,
            endedAt: self.endedAt,
            timeLimitMinutes: self.timeLimitMinutes,
            tournamentId: self.$tournament.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TournamentRound {
    struct CreateRequest: Content {
        var roundNumber: Int
        var status: TournamentRoundStatus = .pending
        var startedAt: Date?
        var endedAt: Date?
        var timeLimitMinutes: Int = 50
        var tournamentId: UUID
    }

    struct UpdateRequest: Content {
        var roundNumber: Int?
        var status: TournamentRoundStatus?
        var startedAt: Date??
        var endedAt: Date??
        var timeLimitMinutes: Int?
        var tournamentId: UUID??
    }
}