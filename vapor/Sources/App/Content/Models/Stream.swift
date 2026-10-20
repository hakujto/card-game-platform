import Vapor
import Fluent

enum StreamStatus: String, Codable, CaseIterable {
    case scheduled = "Scheduled"
    case live = "Live"
    case ended = "Ended"
}

enum StreamPlatform: String, Codable, CaseIterable {
    case twitch = "Twitch"
    case youTube = "YouTube"
    case kickStream = "KickStream"
    case platform = "Platform"
}

enum StreamLanguage: String, Codable, CaseIterable {
    case eN = "EN"
    case dE = "DE"
    case fR = "FR"
    case iT = "IT"
    case eS = "ES"
    case jP = "JP"
    case pT = "PT"
}

final class Stream: Model, Content {
    static let schema = "streams"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "stream_url")
    var streamUrl: String

    @Field(key: "status")
    var status: StreamStatus

    @Field(key: "platform")
    var platform: StreamPlatform

    @Field(key: "language")
    var language: StreamLanguage

    @Field(key: "is_official")
    var isOfficial: Bool

    @Field(key: "viewer_count_peak")
    var viewerCountPeak: Int

    @Field(key: "scheduled_start")
    var scheduledStart: Date

    @OptionalField(key: "actual_start")
    var actualStart: Date?

    @OptionalField(key: "ended_at")
    var endedAt: Date?

    @OptionalField(key: "vod_url")
    var vodUrl: String?

    @OptionalParent(key: "tournament_id")
    var tournament: Tournament?

    @Parent(key: "streamer_id")
    var streamer: Player

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        title: String,
        streamUrl: String,
        status: StreamStatus = .scheduled,
        platform: StreamPlatform = .twitch,
        language: StreamLanguage = .eN,
        isOfficial: Bool = false,
        viewerCountPeak: Int = 0,
        scheduledStart: Date,
        actualStart: Date?,
        endedAt: Date?,
        vodUrl: String?,
        tournamentID: UUID? = nil,
        streamerID: UUID
    ) {
        self.id = id
        self.title = title
        self.streamUrl = streamUrl
        self.status = status
        self.platform = platform
        self.language = language
        self.isOfficial = isOfficial
        self.viewerCountPeak = viewerCountPeak
        self.scheduledStart = scheduledStart
        self.actualStart = actualStart
        self.endedAt = endedAt
        self.vodUrl = vodUrl
        self.$tournament.id = tournamentID
        self.$streamer.id = streamerID
    }

    struct DTO: Content {
        var id: UUID?
        var title: String
        var streamUrl: String
        var status: StreamStatus
        var platform: StreamPlatform
        var language: StreamLanguage
        var isOfficial: Bool
        var viewerCountPeak: Int
        var scheduledStart: Date
        var actualStart: Date?
        var endedAt: Date?
        var vodUrl: String?
        var tournamentId: UUID?
        var streamerId: UUID?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            title: self.title,
            streamUrl: self.streamUrl,
            status: self.status,
            platform: self.platform,
            language: self.language,
            isOfficial: self.isOfficial,
            viewerCountPeak: self.viewerCountPeak,
            scheduledStart: self.scheduledStart,
            actualStart: self.actualStart,
            endedAt: self.endedAt,
            vodUrl: self.vodUrl,
            tournamentId: self.$tournament.id,
            streamerId: self.$streamer.id,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Stream {
    struct CreateRequest: Content {
        var title: String
        var streamUrl: String
        var status: StreamStatus = .scheduled
        var platform: StreamPlatform = .twitch
        var language: StreamLanguage = .eN
        var isOfficial: Bool = false
        var viewerCountPeak: Int = 0
        var scheduledStart: Date
        var actualStart: Date?
        var endedAt: Date?
        var vodUrl: String?
        var tournamentId: UUID?
        var streamerId: UUID
    }

    struct UpdateRequest: Content {
        var title: String?
        var streamUrl: String?
        var status: StreamStatus?
        var platform: StreamPlatform?
        var language: StreamLanguage?
        var isOfficial: Bool?
        var viewerCountPeak: Int?
        var scheduledStart: Date?
        var actualStart: Date??
        var endedAt: Date??
        var vodUrl: String??
        var tournamentId: UUID??
        var streamerId: UUID??
    }
}