#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum AchievementRarity {
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

impl AchievementRarity {
    pub fn as_str(&self) -> &'static str {
        match self {
            AchievementRarity::Common => "Common",
            AchievementRarity::Uncommon => "Uncommon",
            AchievementRarity::Rare => "Rare",
            AchievementRarity::Epic => "Epic",
            AchievementRarity::Legendary => "Legendary",
        }
    }
}

impl std::fmt::Display for AchievementRarity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for AchievementRarity {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Common" => Ok(AchievementRarity::Common),
            "Uncommon" => Ok(AchievementRarity::Uncommon),
            "Rare" => Ok(AchievementRarity::Rare),
            "Epic" => Ok(AchievementRarity::Epic),
            "Legendary" => Ok(AchievementRarity::Legendary),
            _ => Err(format!("unknown AchievementRarity: {}", s)),
        }
    }
}

impl From<String> for AchievementRarity {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid AchievementRarity: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Achievement {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub description: String,
    pub icon_url: Option<String>,
    pub points: i64,
    pub rarity: AchievementRarity,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_hidden: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct AchievementCreateRequest {
    pub name: String,
    pub description: String,
    pub icon_url: Option<String>,
    pub points: i64,
    pub rarity: AchievementRarity,
    pub is_hidden: bool,
}

#[derive(Debug, serde::Deserialize)]
pub struct AchievementUpdateRequest {
    pub name: Option<String>,
    pub description: Option<String>,
    pub icon_url: Option<String>,
    pub points: Option<i64>,
    pub rarity: Option<AchievementRarity>,
    pub is_hidden: Option<bool>,
}
