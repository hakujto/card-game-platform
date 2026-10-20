import Vapor
import Fluent

enum TournamentStatus: String, Codable, CaseIterable {
    case draft = "Draft"
    case registration = "Registration"
    case ongoing = "Ongoing"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

enum TournamentFormat: String, Codable, CaseIterable {
    case standard = "Standard"
    case extended = "Extended"
    case legacy = "Legacy"
    case vintage = "Vintage"
    case commander = "Commander"
    case draft = "Draft"
}

enum TournamentTournamentType: String, Codable, CaseIterable {
    case swiss = "Swiss"
    case singleElimination = "SingleElimination"
    case doubleElimination = "DoubleElimination"
    case roundRobin = "RoundRobin"
}

// Hook: after_update → sync_season_stats
// Hook: before_delete → prevent_delete_if_ongoing

// Audit: track changes (track, actor)

final class Tournament: Model, Content {
    static let schema = "tournaments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "public_id")
    var publicId: UUID

    @Field(key: "name")
    var name: String

    @OptionalField(key: "description")
    var description: String?

    @Field(key: "status")
    var status: TournamentStatus

    @OptionalField(key: "bracket_data")
    var bracketData: String?

    @Field(key: "format")
    var format: TournamentFormat

    @Field(key: "tournament_type")
    var tournamentType: TournamentTournamentType

    @Field(key: "max_players")
    var maxPlayers: Int

    @Field(key: "entry_fee")
    var entryFee: Double

    @Field(key: "prize_pool")
    var prizePool: Double

    @Field(key: "start_time")
    var startTime: Date

    @OptionalField(key: "end_time")
    var endTime: Date?

    @Field(key: "is_online")
    var isOnline: Bool

    @OptionalField(key: "location")
    var location: String?

    @OptionalField(key: "rules_text")
    var rulesText: String?

    @Parent(key: "season_id")
    var season: Season

    @Parent(key: "organizer_id")
    var organizer: Player

    @Siblings(through: TournamentJudge.self, from: \TournamentJudge.$tournament, to: \TournamentJudge.$player)
    var judges: [Player]

    @Children(for: \TournamentJudge.$tournament)
    var judgeAssignments: [TournamentJudge]

    @Children(for: \TournamentRegistration.$tournament)
    var registrations: [TournamentRegistration]

    @Children(for: \TournamentRound.$tournament)
    var rounds: [TournamentRound]

    @Children(for: \TournamentPrize.$tournament)
    var prizes: [TournamentPrize]

    @Children(for: \Stream.$tournament)
    var streams: [Stream]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        publicId: UUID,
        name: String,
        description: String?,
        status: TournamentStatus = .draft,
        bracketData: String?,
        format: TournamentFormat = .standard,
        tournamentType: TournamentTournamentType = .swiss,
        maxPlayers: Int,
        entryFee: Double = 0,
        prizePool: Double = 0,
        startTime: Date,
        endTime: Date?,
        isOnline: Bool = true,
        location: String?,
        rulesText: String?,
        seasonID: UUID,
        organizerID: UUID
    ) {
        self.id = id
        self.publicId = publicId
        self.name = name
        self.description = description
        self.status = status
        self.bracketData = bracketData
        self.format = format
        self.tournamentType = tournamentType
        self.maxPlayers = maxPlayers
        self.entryFee = entryFee
        self.prizePool = prizePool
        self.startTime = startTime
        self.endTime = endTime
        self.isOnline = isOnline
        self.location = location
        self.rulesText = rulesText
        self.$season.id = seasonID
        self.$organizer.id = organizerID
    }

    struct DTO: Content {
        var id: UUID?
        var publicId: UUID
        var name: String
        var description: String?
        var status: TournamentStatus
        var bracketData: String?
        var format: TournamentFormat
        var tournamentType: TournamentTournamentType
        var maxPlayers: Int
        var entryFee: Double
        var prizePool: Double
        var startTime: Date
        var endTime: Date?
        var isOnline: Bool
        var location: String?
        var rulesText: String?
        var seasonId: UUID?
        var organizerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            publicId: self.publicId,
            name: self.name,
            description: self.description,
            status: self.status,
            bracketData: self.bracketData,
            format: self.format,
            tournamentType: self.tournamentType,
            maxPlayers: self.maxPlayers,
            entryFee: self.entryFee,
            prizePool: self.prizePool,
            startTime: self.startTime,
            endTime: self.endTime,
            isOnline: self.isOnline,
            location: self.location,
            rulesText: self.rulesText,
            seasonId: self.$season.id,
            organizerId: self.$organizer.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Tournament {
    struct CreateRequest: Content {
        var publicId: UUID
        var name: String
        var description: String?
        var status: TournamentStatus = .draft
        var bracketData: String?
        var format: TournamentFormat = .standard
        var tournamentType: TournamentTournamentType = .swiss
        var maxPlayers: Int
        var entryFee: Double = 0
        var prizePool: Double = 0
        var startTime: Date
        var endTime: Date?
        var isOnline: Bool = true
        var location: String?
        var rulesText: String?
        var seasonId: UUID
        var organizerId: UUID
    }

    struct UpdateRequest: Content {
        var publicId: UUID?
        var name: String?
        var description: String??
        var bracketData: String??
        var format: TournamentFormat?
        var tournamentType: TournamentTournamentType?
        var maxPlayers: Int?
        var entryFee: Double?
        var prizePool: Double?
        var startTime: Date?
        var endTime: Date??
        var isOnline: Bool?
        var location: String??
        var rulesText: String??
        var seasonId: UUID??
        var organizerId: UUID??
    }
}