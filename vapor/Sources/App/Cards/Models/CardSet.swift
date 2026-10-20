import Vapor
import Fluent

enum CardSetSetType: String, Codable, CaseIterable {
    case core = "Core"
    case expansion = "Expansion"
    case supplemental = "Supplemental"
    case masters = "Masters"
    case draft = "Draft"
}

final class CardSet: Model, Content {
    static let schema = "card_sets"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "code")
    var code: String

    @Field(key: "release_date")
    var releaseDate: String

    @OptionalField(key: "rotation_date")
    var rotationDate: String?

    @Field(key: "set_type")
    var setType: CardSetSetType

    @Field(key: "total_cards")
    var totalCards: Int

    @Field(key: "is_rotated")
    var isRotated: Bool

    @OptionalField(key: "description")
    var description: String?

    @OptionalField(key: "logo_url")
    var logoUrl: String?

    @Children(for: \Card.$set)
    var cards: [Card]

    @Children(for: \Product.$cardSet)
    var shopProducts: [Product]

    @Children(for: \DraftSession.$cardSet)
    var draftSessions: [DraftSession]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        code: String,
        releaseDate: String,
        rotationDate: String?,
        setType: CardSetSetType = .expansion,
        totalCards: Int,
        isRotated: Bool = false,
        description: String?,
        logoUrl: String?
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.releaseDate = releaseDate
        self.rotationDate = rotationDate
        self.setType = setType
        self.totalCards = totalCards
        self.isRotated = isRotated
        self.description = description
        self.logoUrl = logoUrl
    }

    struct DTO: Content {
        var id: UUID?
        var name: String
        var code: String
        var releaseDate: String
        var rotationDate: String?
        var setType: CardSetSetType
        var totalCards: Int
        var isRotated: Bool
        var description: String?
        var logoUrl: String?
        var createdAt: Date?
        var updatedAt: Date?
    }

    func toDTO() -> DTO {
        DTO(
            id: self.id,
            name: self.name,
            code: self.code,
            releaseDate: self.releaseDate,
            rotationDate: self.rotationDate,
            setType: self.setType,
            totalCards: self.totalCards,
            isRotated: self.isRotated,
            description: self.description,
            logoUrl: self.logoUrl,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension CardSet {
    struct CreateRequest: Content {
        var name: String
        var code: String
        var releaseDate: String
        var rotationDate: String?
        var setType: CardSetSetType = .expansion
        var totalCards: Int
        var isRotated: Bool = false
        var description: String?
        var logoUrl: String?
    }

    struct UpdateRequest: Content {
        var name: String?
        var code: String?
        var releaseDate: String?
        var rotationDate: String??
        var setType: CardSetSetType?
        var totalCards: Int?
        var isRotated: Bool?
        var description: String??
        var logoUrl: String??
    }
}