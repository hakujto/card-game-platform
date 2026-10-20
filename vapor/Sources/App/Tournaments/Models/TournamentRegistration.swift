import Vapor
import Fluent

enum TournamentRegistrationStatus: String, Codable, CaseIterable {
    case registered = "Registered"
    case waitlisted = "Waitlisted"
    case withdrawn = "Withdrawn"
    case disqualified = "Disqualified"
}

final class TournamentRegistration: Model, Content {
    static let schema = "tournament_registrations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "status")
    var status: TournamentRegistrationStatus

    @OptionalField(key: "seed")
    var seed: Int?

    @OptionalField(key: "final_standing")
    var finalStanding: Int?

    @Field(key: "points_earned")
    var pointsEarned: Int

    @Field(key: "registered_at")
    var registeredAt: Date

    @Parent(key: "tournament_id")
    var tournament: Tournament

    @Parent(key: "player_id")
    var player: Player

    @Parent(key: "deck_id")
    var deck: Deck

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        status: TournamentRegistrationStatus = .registered,
        seed: Int?,
        finalStanding: Int?,
        pointsEarned: Int = 0,
        registeredAt: Date,
        tournamentID: UUID,
        playerID: UUID,
        deckID: UUID
    ) {
        self.id = id
        self.status = status
        self.seed = seed
        self.finalStanding = finalStanding
        self.pointsEarned = pointsEarned
        self.registeredAt = registeredAt
        self.$tournament.id = tournamentID
        self.$player.id = playerID
        self.$deck.id = deckID
    }

    struct DTO: Content {
        var id: UUID?
        var status: TournamentRegistrationStatus
        var seed: Int?
        var finalStanding: Int?
        var pointsEarned: Int
        var registeredAt: Date
        var tournamentId: UUID?
        var playerId: UUID?
        var deckId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            status: self.status,
            seed: self.seed,
            finalStanding: self.finalStanding,
            pointsEarned: self.pointsEarned,
            registeredAt: self.registeredAt,
            tournamentId: self.$tournament.id,
            playerId: self.$player.id,
            deckId: self.$deck.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension TournamentRegistration {
    struct CreateRequest: Content {
        var status: TournamentRegistrationStatus = .registered
        var seed: Int?
        var finalStanding: Int?
        var pointsEarned: Int = 0
        var registeredAt: Date
        var tournamentId: UUID
        var playerId: UUID
        var deckId: UUID
    }

    struct UpdateRequest: Content {
        var status: TournamentRegistrationStatus?
        var seed: Int??
        var finalStanding: Int??
        var pointsEarned: Int?
        var registeredAt: Date?
        var tournamentId: UUID??
        var playerId: UUID??
        var deckId: UUID??
    }
}