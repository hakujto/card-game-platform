import Vapor
import Fluent

enum TournamentJudgeRole: String, Codable, CaseIterable {
    case headJudge = "HeadJudge"
    case judge = "Judge"
    case scorekeeperJudge = "ScorekeeperJudge"
}

final class TournamentJudge: Model, Content {
    static let schema = "tournament_judges"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "role")
    var role: TournamentJudgeRole

    @Parent(key: "tournament_id")
    var tournament: Tournament

    @Parent(key: "player_id")
    var player: Player

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        role: TournamentJudgeRole = .judge,
        tournamentID: UUID,
        playerID: UUID
    ) {
        self.id = id
        self.role = role
        self.$tournament.id = tournamentID
        self.$player.id = playerID
    }

    struct DTO: Content {
        var id: UUID?
        var role: TournamentJudgeRole
        var tournamentId: UUID?
        var playerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            role: self.role,
            tournamentId: self.$tournament.id,
            playerId: self.$player.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TournamentJudge {
    struct CreateRequest: Content {
        var role: TournamentJudgeRole = .judge
        var tournamentId: UUID
        var playerId: UUID
    }

    struct UpdateRequest: Content {
        var role: TournamentJudgeRole?
        var tournamentId: UUID??
        var playerId: UUID??
    }
}