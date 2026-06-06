#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentRegistrationStatus {
    Registered,
    Waitlisted,
    Withdrawn,
    Disqualified,
}

impl TournamentRegistrationStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentRegistrationStatus::Registered => "Registered",
            TournamentRegistrationStatus::Waitlisted => "Waitlisted",
            TournamentRegistrationStatus::Withdrawn => "Withdrawn",
            TournamentRegistrationStatus::Disqualified => "Disqualified",
        }
    }
}

impl std::fmt::Display for TournamentRegistrationStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentRegistrationStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Registered" => Ok(TournamentRegistrationStatus::Registered),
            "Waitlisted" => Ok(TournamentRegistrationStatus::Waitlisted),
            "Withdrawn" => Ok(TournamentRegistrationStatus::Withdrawn),
            "Disqualified" => Ok(TournamentRegistrationStatus::Disqualified),
            _ => Err(format!("unknown TournamentRegistrationStatus: {}", s)),
        }
    }
}

impl From<String> for TournamentRegistrationStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentRegistrationStatus: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TournamentRegistration {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub status: TournamentRegistrationStatus,
    pub seed: Option<i64>,
    pub final_standing: Option<i64>,
    pub points_earned: i64,
    #[serde(rename = "registeredAt")]
    pub registered_at: String,
    pub tournament_id: i64,
    pub player_id: i64,
    pub deck_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentRegistrationCreateRequest {
    pub status: TournamentRegistrationStatus,
    pub seed: Option<i64>,
    pub final_standing: Option<i64>,
    pub points_earned: i64,
    pub registered_at: String,
    pub tournament_id: i64,
    pub player_id: i64,
    pub deck_id: i64,
}
