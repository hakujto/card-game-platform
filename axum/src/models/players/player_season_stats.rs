#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum PlayerSeasonStatsHighestRank {
    Bronze,
    Silver,
    Gold,
    Platinum,
    Diamond,
    Master,
    Grandmaster,
}

impl PlayerSeasonStatsHighestRank {
    pub fn as_str(&self) -> &'static str {
        match self {
            PlayerSeasonStatsHighestRank::Bronze => "Bronze",
            PlayerSeasonStatsHighestRank::Silver => "Silver",
            PlayerSeasonStatsHighestRank::Gold => "Gold",
            PlayerSeasonStatsHighestRank::Platinum => "Platinum",
            PlayerSeasonStatsHighestRank::Diamond => "Diamond",
            PlayerSeasonStatsHighestRank::Master => "Master",
            PlayerSeasonStatsHighestRank::Grandmaster => "Grandmaster",
        }
    }
}

impl std::fmt::Display for PlayerSeasonStatsHighestRank {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for PlayerSeasonStatsHighestRank {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Bronze" => Ok(PlayerSeasonStatsHighestRank::Bronze),
            "Silver" => Ok(PlayerSeasonStatsHighestRank::Silver),
            "Gold" => Ok(PlayerSeasonStatsHighestRank::Gold),
            "Platinum" => Ok(PlayerSeasonStatsHighestRank::Platinum),
            "Diamond" => Ok(PlayerSeasonStatsHighestRank::Diamond),
            "Master" => Ok(PlayerSeasonStatsHighestRank::Master),
            "Grandmaster" => Ok(PlayerSeasonStatsHighestRank::Grandmaster),
            _ => Err(format!("unknown PlayerSeasonStatsHighestRank: {}", s)),
        }
    }
}

impl From<String> for PlayerSeasonStatsHighestRank {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid PlayerSeasonStatsHighestRank: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct PlayerSeasonStats {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub wins: i64,
    pub losses: i64,
    pub draws: i64,
    pub tournament_wins: i64,
    pub highest_rank: Option<PlayerSeasonStatsHighestRank>,
    pub season_points: i64,
    pub player_id: i64,
    pub season_id: i64,
}
