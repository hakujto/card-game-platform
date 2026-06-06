#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum CardSetSetType {
    Core,
    Expansion,
    Supplemental,
    Masters,
    Draft,
}

impl CardSetSetType {
    pub fn as_str(&self) -> &'static str {
        match self {
            CardSetSetType::Core => "Core",
            CardSetSetType::Expansion => "Expansion",
            CardSetSetType::Supplemental => "Supplemental",
            CardSetSetType::Masters => "Masters",
            CardSetSetType::Draft => "Draft",
        }
    }
}

impl std::fmt::Display for CardSetSetType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for CardSetSetType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Core" => Ok(CardSetSetType::Core),
            "Expansion" => Ok(CardSetSetType::Expansion),
            "Supplemental" => Ok(CardSetSetType::Supplemental),
            "Masters" => Ok(CardSetSetType::Masters),
            "Draft" => Ok(CardSetSetType::Draft),
            _ => Err(format!("unknown CardSetSetType: {}", s)),
        }
    }
}

impl From<String> for CardSetSetType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid CardSetSetType: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct CardSet {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub code: String,
    pub release_date: String,
    pub rotation_date: Option<String>,
    pub set_type: CardSetSetType,
    pub total_cards: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_rotated: i64,
    pub description: Option<String>,
    pub logo_url: Option<String>,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardSetCreateRequest {
    pub name: String,
    pub code: String,
    pub release_date: String,
    pub rotation_date: Option<String>,
    pub set_type: CardSetSetType,
    pub total_cards: i64,
    pub is_rotated: bool,
    pub description: Option<String>,
    pub logo_url: Option<String>,
}

#[derive(Debug, serde::Deserialize)]
pub struct CardSetUpdateRequest {
    pub name: Option<String>,
    pub code: Option<String>,
    pub release_date: Option<String>,
    pub rotation_date: Option<String>,
    pub set_type: Option<CardSetSetType>,
    pub total_cards: Option<i64>,
    pub is_rotated: Option<bool>,
    pub description: Option<String>,
    pub logo_url: Option<String>,
}
