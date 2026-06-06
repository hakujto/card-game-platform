#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentStatus {
    Draft,
    Registration,
    Ongoing,
    Completed,
    Cancelled,
}

impl TournamentStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentStatus::Draft => "Draft",
            TournamentStatus::Registration => "Registration",
            TournamentStatus::Ongoing => "Ongoing",
            TournamentStatus::Completed => "Completed",
            TournamentStatus::Cancelled => "Cancelled",
        }
    }
}

impl std::fmt::Display for TournamentStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Draft" => Ok(TournamentStatus::Draft),
            "Registration" => Ok(TournamentStatus::Registration),
            "Ongoing" => Ok(TournamentStatus::Ongoing),
            "Completed" => Ok(TournamentStatus::Completed),
            "Cancelled" => Ok(TournamentStatus::Cancelled),
            _ => Err(format!("unknown TournamentStatus: {}", s)),
        }
    }
}

impl From<String> for TournamentStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentStatus: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentFormat {
    Standard,
    Extended,
    Legacy,
    Vintage,
    Commander,
    Draft,
}

impl TournamentFormat {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentFormat::Standard => "Standard",
            TournamentFormat::Extended => "Extended",
            TournamentFormat::Legacy => "Legacy",
            TournamentFormat::Vintage => "Vintage",
            TournamentFormat::Commander => "Commander",
            TournamentFormat::Draft => "Draft",
        }
    }
}

impl std::fmt::Display for TournamentFormat {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentFormat {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Standard" => Ok(TournamentFormat::Standard),
            "Extended" => Ok(TournamentFormat::Extended),
            "Legacy" => Ok(TournamentFormat::Legacy),
            "Vintage" => Ok(TournamentFormat::Vintage),
            "Commander" => Ok(TournamentFormat::Commander),
            "Draft" => Ok(TournamentFormat::Draft),
            _ => Err(format!("unknown TournamentFormat: {}", s)),
        }
    }
}

impl From<String> for TournamentFormat {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentFormat: {}", s))
    }
}

#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentTournamentType {
    Swiss,
    SingleElimination,
    DoubleElimination,
    RoundRobin,
}

impl TournamentTournamentType {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentTournamentType::Swiss => "Swiss",
            TournamentTournamentType::SingleElimination => "SingleElimination",
            TournamentTournamentType::DoubleElimination => "DoubleElimination",
            TournamentTournamentType::RoundRobin => "RoundRobin",
        }
    }
}

impl std::fmt::Display for TournamentTournamentType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentTournamentType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Swiss" => Ok(TournamentTournamentType::Swiss),
            "SingleElimination" => Ok(TournamentTournamentType::SingleElimination),
            "DoubleElimination" => Ok(TournamentTournamentType::DoubleElimination),
            "RoundRobin" => Ok(TournamentTournamentType::RoundRobin),
            _ => Err(format!("unknown TournamentTournamentType: {}", s)),
        }
    }
}

impl From<String> for TournamentTournamentType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentTournamentType: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Tournament {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub name: String,
    pub description: Option<String>,
    pub status: TournamentStatus,
    pub format: TournamentFormat,
    pub tournament_type: TournamentTournamentType,
    pub max_players: i64,
    pub entry_fee: f64,
    pub prize_pool: f64,
    #[serde(rename = "startTime")]
    pub start_time: String,
    #[serde(rename = "endTime")]
    pub end_time: Option<String>,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_online: i64,
    pub location: Option<String>,
    pub rules_text: Option<String>,
    pub season_id: i64,
    pub organizer_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentCreateRequest {
    pub name: String,
    pub description: Option<String>,
    pub status: TournamentStatus,
    pub format: TournamentFormat,
    pub tournament_type: TournamentTournamentType,
    pub max_players: i64,
    pub entry_fee: f64,
    pub prize_pool: f64,
    pub start_time: String,
    pub end_time: Option<String>,
    pub is_online: bool,
    pub location: Option<String>,
    pub rules_text: Option<String>,
    pub season_id: i64,
    pub organizer_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentUpdateRequest {
    pub name: Option<String>,
    pub description: Option<String>,
    pub status: Option<TournamentStatus>,
    pub format: Option<TournamentFormat>,
    pub tournament_type: Option<TournamentTournamentType>,
    pub max_players: Option<i64>,
    pub entry_fee: Option<f64>,
    pub prize_pool: Option<f64>,
    pub start_time: Option<String>,
    pub end_time: Option<String>,
    pub is_online: Option<bool>,
    pub location: Option<String>,
    pub rules_text: Option<String>,
    pub season_id: Option<i64>,
    pub organizer_id: Option<i64>,
}

impl Tournament {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Draft", "Registration"),
            ("Registration", "Ongoing"),
            ("Registration", "Cancelled"),
            ("Ongoing", "Completed"),
            ("Ongoing", "Cancelled"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
