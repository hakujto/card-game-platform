#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum PlayerRank {
    Bronze,
    Silver,
    Gold,
    Platinum,
    Diamond,
    Master,
    Grandmaster,
}

impl PlayerRank {
    pub fn as_str(&self) -> &'static str {
        match self {
            PlayerRank::Bronze => "Bronze",
            PlayerRank::Silver => "Silver",
            PlayerRank::Gold => "Gold",
            PlayerRank::Platinum => "Platinum",
            PlayerRank::Diamond => "Diamond",
            PlayerRank::Master => "Master",
            PlayerRank::Grandmaster => "Grandmaster",
        }
    }
}

impl std::fmt::Display for PlayerRank {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for PlayerRank {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Bronze" => Ok(PlayerRank::Bronze),
            "Silver" => Ok(PlayerRank::Silver),
            "Gold" => Ok(PlayerRank::Gold),
            "Platinum" => Ok(PlayerRank::Platinum),
            "Diamond" => Ok(PlayerRank::Diamond),
            "Master" => Ok(PlayerRank::Master),
            "Grandmaster" => Ok(PlayerRank::Grandmaster),
            _ => Err(format!("unknown PlayerRank: {}", s)),
        }
    }
}

impl From<String> for PlayerRank {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid PlayerRank: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum PlayerPreferredFormat {
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft,
}

impl PlayerPreferredFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            PlayerPreferredFormat::Standard => "Standard",
            PlayerPreferredFormat::Extended => "Extended",
            PlayerPreferredFormat::Legacy => "Legacy",
            PlayerPreferredFormat::Vintage => "Vintage",
            PlayerPreferredFormat::Commander => "Commander",
            PlayerPreferredFormat::Draft => "Draft",
        }
    }
}

impl std::fmt::Display for PlayerPreferredFormat {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for PlayerPreferredFormat {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Standard" => Ok(PlayerPreferredFormat::Standard),
            "Extended" => Ok(PlayerPreferredFormat::Extended),
            "Legacy" => Ok(PlayerPreferredFormat::Legacy),
            "Vintage" => Ok(PlayerPreferredFormat::Vintage),
            "Commander" => Ok(PlayerPreferredFormat::Commander),
            "Draft" => Ok(PlayerPreferredFormat::Draft),
            _ => Err(format!("unknown PlayerPreferredFormat: {}", s)),
        }
    }
}

impl From<String> for PlayerPreferredFormat {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid PlayerPreferredFormat: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Player {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub display_name: String,
    pub rank: PlayerRank,
    pub rating: i64,
    pub peak_rating: i64,
    pub bio: Option<String>,
    pub country_code: Option<String>,
    pub avatar_url: Option<String>,
    pub preferred_format: Option<PlayerPreferredFormat>,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_verified: i64,
    #[serde(rename = "lastActiveAt")]
    pub last_active_at: Option<String>,
    pub user_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct PlayerCreateRequest {
    pub display_name: String,
    pub rank: PlayerRank,
    pub rating: i64,
    pub peak_rating: i64,
    pub bio: Option<String>,
    pub country_code: Option<String>,
    pub avatar_url: Option<String>,
    pub preferred_format: Option<PlayerPreferredFormat>,
    pub is_verified: bool,
    pub last_active_at: Option<String>,
    pub user_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct PlayerUpdateRequest {
    pub display_name: Option<String>,
    pub rank: Option<PlayerRank>,
    pub rating: Option<i64>,
    pub peak_rating: Option<i64>,
    pub bio: Option<String>,
    pub country_code: Option<String>,
    pub avatar_url: Option<String>,
    pub preferred_format: Option<PlayerPreferredFormat>,
    pub is_verified: Option<bool>,
    pub last_active_at: Option<String>,
    pub user_id: Option<i64>,
}
