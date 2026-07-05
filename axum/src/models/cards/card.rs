#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardCardType {
    Creature,
    Spell,
    Land,
    Artifact,
    Enchantment,
    Planeswalker,
}

impl CardCardType {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardCardType::Creature => "Creature",
            CardCardType::Spell => "Spell",
            CardCardType::Land => "Land",
            CardCardType::Artifact => "Artifact",
            CardCardType::Enchantment => "Enchantment",
            CardCardType::Planeswalker => "Planeswalker",
        }
    }
}

impl std::fmt::Display for CardCardType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardCardType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Creature" => Ok(CardCardType::Creature),
            "Spell" => Ok(CardCardType::Spell),
            "Land" => Ok(CardCardType::Land),
            "Artifact" => Ok(CardCardType::Artifact),
            "Enchantment" => Ok(CardCardType::Enchantment),
            "Planeswalker" => Ok(CardCardType::Planeswalker),
            _ => Err(format!("unknown CardCardType: {}", s)),
        }
    }
}

impl From<String> for CardCardType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardCardType: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardRarity {
    Common,
    Uncommon,
    Rare,
    MythicRare,
    Legendary,
}

impl CardRarity {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardRarity::Common => "Common",
            CardRarity::Uncommon => "Uncommon",
            CardRarity::Rare => "Rare",
            CardRarity::MythicRare => "MythicRare",
            CardRarity::Legendary => "Legendary",
        }
    }
}

impl std::fmt::Display for CardRarity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardRarity {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Common" => Ok(CardRarity::Common),
            "Uncommon" => Ok(CardRarity::Uncommon),
            "Rare" => Ok(CardRarity::Rare),
            "MythicRare" => Ok(CardRarity::MythicRare),
            "Legendary" => Ok(CardRarity::Legendary),
            _ => Err(format!("unknown CardRarity: {}", s)),
        }
    }
}

impl From<String> for CardRarity {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardRarity: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardManaColors {
    White,
    Blue,
    Black,
    Red,
    Green,
    Colorless,
}

impl CardManaColors {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardManaColors::White => "White",
            CardManaColors::Blue => "Blue",
            CardManaColors::Black => "Black",
            CardManaColors::Red => "Red",
            CardManaColors::Green => "Green",
            CardManaColors::Colorless => "Colorless",
        }
    }
}

impl std::fmt::Display for CardManaColors {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardManaColors {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "White" => Ok(CardManaColors::White),
            "Blue" => Ok(CardManaColors::Blue),
            "Black" => Ok(CardManaColors::Black),
            "Red" => Ok(CardManaColors::Red),
            "Green" => Ok(CardManaColors::Green),
            "Colorless" => Ok(CardManaColors::Colorless),
            _ => Err(format!("unknown CardManaColors: {}", s)),
        }
    }
}

impl From<String> for CardManaColors {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardManaColors: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardLegalFormats {
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft,
}

impl CardLegalFormats {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardLegalFormats::Standard => "Standard",
            CardLegalFormats::Extended => "Extended",
            CardLegalFormats::Legacy => "Legacy",
            CardLegalFormats::Vintage => "Vintage",
            CardLegalFormats::Commander => "Commander",
            CardLegalFormats::Draft => "Draft",
        }
    }
}

impl std::fmt::Display for CardLegalFormats {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardLegalFormats {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Standard" => Ok(CardLegalFormats::Standard),
            "Extended" => Ok(CardLegalFormats::Extended),
            "Legacy" => Ok(CardLegalFormats::Legacy),
            "Vintage" => Ok(CardLegalFormats::Vintage),
            "Commander" => Ok(CardLegalFormats::Commander),
            "Draft" => Ok(CardLegalFormats::Draft),
            _ => Err(format!("unknown CardLegalFormats: {}", s)),
        }
    }
}

impl From<String> for CardLegalFormats {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardLegalFormats: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Card {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub public_id: String,
    pub name: String,
    pub card_type: CardCardType,
    pub rarity: CardRarity,
    pub mana_cost: i64,
    pub mana_colors: CardManaColors,
    pub attack: Option<i64>,
    pub defense: Option<i64>,
    pub loyalty: Option<i64>,
    pub description: String,
    pub flavor_text: Option<String>,
    pub image_url: Option<String>,
    pub artist_name: Option<String>,
    pub legal_formats: CardLegalFormats,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_banned: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_restricted: i64,
    pub power_level: i64,
    pub metadata: Option<serde_json::Value>,
    pub total_copies_in_circulation: i64,
    pub set_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardCreateRequest {
    pub public_id: String,
    pub name: String,
    pub card_type: CardCardType,
    pub rarity: CardRarity,
    pub mana_cost: i64,
    pub mana_colors: CardManaColors,
    pub attack: Option<i64>,
    pub defense: Option<i64>,
    pub loyalty: Option<i64>,
    pub description: String,
    pub flavor_text: Option<String>,
    pub image_url: Option<String>,
    pub artist_name: Option<String>,
    pub legal_formats: CardLegalFormats,
    pub is_banned: bool,
    pub is_restricted: bool,
    pub power_level: i64,
    pub metadata: Option<serde_json::Value>,
    pub total_copies_in_circulation: i64,
    pub set_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardUpdateRequest {
    pub public_id: Option<String>,
    pub name: Option<String>,
    pub card_type: Option<CardCardType>,
    pub rarity: Option<CardRarity>,
    pub mana_cost: Option<i64>,
    pub mana_colors: Option<CardManaColors>,
    pub attack: Option<i64>,
    pub defense: Option<i64>,
    pub loyalty: Option<i64>,
    pub description: Option<String>,
    pub flavor_text: Option<String>,
    pub image_url: Option<String>,
    pub artist_name: Option<String>,
    pub legal_formats: Option<CardLegalFormats>,
    pub power_level: Option<i64>,
    pub metadata: Option<serde_json::Value>,
    pub total_copies_in_circulation: Option<i64>,
    pub set_id: Option<i64>,
}

#[derive(Debug, sqlx::FromRow, serde::Serialize)]
pub struct CardAuditLog {
    pub id: i64,
    pub record_id: i64,
    pub field: String,
    pub old_value: Option<String>,
    pub new_value: Option<String>,
    pub changed_at: String,
}
