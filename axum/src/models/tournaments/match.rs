#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum MatchStatus {
    Pending,
    Active,
    Completed,
    BYE,
    Draw,
}

impl MatchStatus {
    pub fn as_str(&self) -> &'static str {
        match self {
            MatchStatus::Pending => "Pending",
            MatchStatus::Active => "Active",
            MatchStatus::Completed => "Completed",
            MatchStatus::BYE => "BYE",
            MatchStatus::Draw => "Draw",
        }
    }
}

impl std::fmt::Display for MatchStatus {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for MatchStatus {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Pending" => Ok(MatchStatus::Pending),
            "Active" => Ok(MatchStatus::Active),
            "Completed" => Ok(MatchStatus::Completed),
            "BYE" => Ok(MatchStatus::BYE),
            "Draw" => Ok(MatchStatus::Draw),
            _ => Err(format!("unknown MatchStatus: {}", s)),
        }
    }
}

impl From<String> for MatchStatus {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid MatchStatus: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct Match {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub table_number: Option<i64>,
    pub status: MatchStatus,
    pub player1_wins: i64,
    pub player2_wins: i64,
    #[serde(rename = "startedAt")]
    pub started_at: Option<String>,
    #[serde(rename = "endedAt")]
    pub ended_at: Option<String>,
    pub result_notes: Option<String>,
    pub round_id: i64,
    pub player1_id: i64,
    pub player2_id: Option<i64>,
}

#[derive(Debug, serde::Deserialize)]
pub struct MatchCreateRequest {
    pub table_number: Option<i64>,
    pub status: MatchStatus,
    pub player1_wins: i64,
    pub player2_wins: i64,
    pub started_at: Option<String>,
    pub ended_at: Option<String>,
    pub result_notes: Option<String>,
    pub round_id: i64,
    pub player1_id: i64,
    pub player2_id: Option<i64>,
}

impl Match {
    pub fn assert_transition(&self, to: &str) -> Result<(), String> {
        let allowed: &[(&str, &str)] = &[
            ("Pending", "Active"),
            ("Active", "Completed"),
            ("Active", "Draw"),
            ("Pending", "BYE"),
        ];
        let current = &self.status;
        if allowed.iter().any(|(from, t)| *from == current.as_str() && *t == to) {
            Ok(())
        } else {
            Err(format!("transition {} -> {} not allowed", current, to))
        }
    }
}
