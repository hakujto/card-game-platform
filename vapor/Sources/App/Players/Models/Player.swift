import Vapor
import Fluent

enum PlayerRank: String, Codable, CaseIterable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
    case master = "Master"
    case grandmaster = "Grandmaster"
}

enum PlayerPreferredFormat: String, Codable, CaseIterable {
    case standard = "Standard"
    case extended = "Extended"
    case legacy = "Legacy"
    case vintage = "Vintage"
    case commander = "Commander"
    case draft = "Draft"
}

// Hook: after_create → initialize_collection
// Hook: after_update → update_rank

final class Player: Model, Content {
    static let schema = "players"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "public_id")
    var publicId: UUID

    @Field(key: "display_name")
    var displayName: String

    @Field(key: "rank")
    var rank: PlayerRank

    @Field(key: "rating")
    var rating: Int

    @Field(key: "peak_rating")
    var peakRating: Int

    @OptionalField(key: "bio")
    var bio: String?

    @OptionalField(key: "country_code")
    var countryCode: String?

    @OptionalField(key: "avatar_url")
    var avatarUrl: String?

    @OptionalField(key: "preferred_format")
    var preferredFormat: PlayerPreferredFormat?

    @OptionalField(key: "contact_email")
    var contactEmail: String?

    @OptionalField(key: "win_rate_cached")
    var winRateCached: Double?

    @Field(key: "is_verified")
    var isVerified: Bool

    @OptionalField(key: "last_active_at")
    var lastActiveAt: Date?

    @Siblings(through: PlayerAchievement.self, from: \PlayerAchievement.$player, to: \PlayerAchievement.$achievement)
    var achievements: [Achievement]

    @Siblings(through: Friendship.self, from: \Friendship.$requester, to: \Friendship.$receiver)
    var friends: [Player]

    @Children(for: \Deck.$player)
    var decks: [Deck]

    @Children(for: \PlayerSeasonStats.$player)
    var seasonStats: [PlayerSeasonStats]

    @Children(for: \PlayerCollection.$player)
    var collection: [PlayerCollection]

    @Children(for: \Friendship.$requester)
    var sentFriendRequests: [Friendship]

    @Children(for: \Friendship.$receiver)
    var receivedFriendRequests: [Friendship]

    @Children(for: \PlayerAchievement.$player)
    var achievementRecords: [PlayerAchievement]

    @Children(for: \Tournament.$organizer)
    var organizedTournaments: [Tournament]

    @Children(for: \TournamentJudge.$player)
    var judgeRoles: [TournamentJudge]

    @Children(for: \TournamentRegistration.$player)
    var tournamentRegistrations: [TournamentRegistration]

    @Children(for: \Match.$player1)
    var matchesAsPlayer1: [Match]

    @Children(for: \Match.$player2)
    var matchesAsPlayer2: [Match]

    @Children(for: \Game.$winner)
    var wonGames: [Game]

    @Children(for: \AwardedPrize.$player)
    var awardedPrizes: [AwardedPrize]

    @Children(for: \Order.$player)
    var orders: [Order]

    @Children(for: \TradeListing.$seller)
    var tradeListings: [TradeListing]

    @Children(for: \TradeBid.$bidder)
    var bids: [TradeBid]

    @Children(for: \TradeTransaction.$buyer)
    var purchases: [TradeTransaction]

    @Children(for: \TradeTransaction.$seller)
    var sales: [TradeTransaction]

    @Children(for: \TradeDispute.$openedBy)
    var disputesOpened: [TradeDispute]

    @Children(for: \TradeDispute.$resolvedBy)
    var disputesResolved: [TradeDispute]

    @Children(for: \DraftParticipant.$player)
    var draftSessions: [DraftParticipant]

    @Children(for: \Article.$author)
    var articles: [Article]

    @Children(for: \ArticleComment.$author)
    var articleComments: [ArticleComment]

    @Children(for: \Stream.$streamer)
    var streams: [Stream]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        publicId: UUID,
        displayName: String,
        rank: PlayerRank = .bronze,
        rating: Int = 1000,
        peakRating: Int = 1000,
        bio: String?,
        countryCode: String?,
        avatarUrl: String?,
        preferredFormat: PlayerPreferredFormat?,
        contactEmail: String?,
        winRateCached: Double?,
        isVerified: Bool = false,
        lastActiveAt: Date?
    ) {
        self.id = id
        self.publicId = publicId
        self.displayName = displayName
        self.rank = rank
        self.rating = rating
        self.peakRating = peakRating
        self.bio = bio
        self.countryCode = countryCode
        self.avatarUrl = avatarUrl
        self.preferredFormat = preferredFormat
        self.contactEmail = contactEmail
        self.winRateCached = winRateCached
        self.isVerified = isVerified
        self.lastActiveAt = lastActiveAt
    }

    struct DTO: Content {
        var id: UUID?
        var publicId: UUID
        var displayName: String
        var rank: PlayerRank
        var rating: Int
        var peakRating: Int
        var bio: String?
        var countryCode: String?
        var avatarUrl: String?
        var preferredFormat: PlayerPreferredFormat?
        var contactEmail: String?
        var winRateCached: Double?
        var isVerified: Bool
        var lastActiveAt: Date?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            publicId: self.publicId,
            displayName: self.displayName,
            rank: self.rank,
            rating: self.rating,
            peakRating: self.peakRating,
            bio: self.bio,
            countryCode: self.countryCode,
            avatarUrl: self.avatarUrl,
            preferredFormat: self.preferredFormat,
            contactEmail: self.contactEmail,
            winRateCached: self.winRateCached,
            isVerified: self.isVerified,
            lastActiveAt: self.lastActiveAt,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension Player {
    struct CreateRequest: Content {
        var publicId: UUID
        var displayName: String
        var rank: PlayerRank = .bronze
        var rating: Int = 1000
        var peakRating: Int = 1000
        var bio: String?
        var countryCode: String?
        var avatarUrl: String?
        var preferredFormat: PlayerPreferredFormat?
        var contactEmail: String?
        var winRateCached: Double?
        var isVerified: Bool = false
        var lastActiveAt: Date?
    }

    struct UpdateRequest: Content {
        var publicId: UUID?
        var displayName: String?
        var rank: PlayerRank?
        var bio: String??
        var countryCode: String??
        var avatarUrl: String??
        var preferredFormat: PlayerPreferredFormat??
        var contactEmail: String??
        var winRateCached: Double??
        var isVerified: Bool?
        var lastActiveAt: Date??
    }
}