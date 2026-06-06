#[derive(Debug, Clone, PartialEq, sqlx::Type, serde::Serialize, serde::Deserialize)]
#[sqlx(type_name = "TEXT", rename_all = "PascalCase")]
pub enum TournamentPrizePrizeType {
    Currency,
    Cards,
    BoosterPacks,
    Trophy,
    SeasonPoints,
    Mixed,
}

impl TournamentPrizePrizeType {
    pub fn as_str(&self) -> &'static str {
        match self {
            TournamentPrizePrizeType::Currency => "Currency",
            TournamentPrizePrizeType::Cards => "Cards",
            TournamentPrizePrizeType::BoosterPacks => "BoosterPacks",
            TournamentPrizePrizeType::Trophy => "Trophy",
            TournamentPrizePrizeType::SeasonPoints => "SeasonPoints",
            TournamentPrizePrizeType::Mixed => "Mixed",
        }
    }
}

impl std::fmt::Display for TournamentPrizePrizeType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

impl std::str::FromStr for TournamentPrizePrizeType {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "Currency" => Ok(TournamentPrizePrizeType::Currency),
            "Cards" => Ok(TournamentPrizePrizeType::Cards),
            "BoosterPacks" => Ok(TournamentPrizePrizeType::BoosterPacks),
            "Trophy" => Ok(TournamentPrizePrizeType::Trophy),
            "SeasonPoints" => Ok(TournamentPrizePrizeType::SeasonPoints),
            "Mixed" => Ok(TournamentPrizePrizeType::Mixed),
            _ => Err(format!("unknown TournamentPrizePrizeType: {}", s)),
        }
    }
}

impl From<String> for TournamentPrizePrizeType {
    fn from(s: String) -> Self {
        s.parse().unwrap_or_else(|_| panic!("invalid TournamentPrizePrizeType: {}", s))
    }
}

#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct TournamentPrize {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub placement_from: i64,
    pub placement_to: i64,
    pub prize_type: TournamentPrizePrizeType,
    pub amount: f64,
    pub description: Option<String>,
    pub packs_count: Option<i64>,
    pub season_points: i64,
    pub tournament_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentPrizeCreateRequest {
    pub placement_from: i64,
    pub placement_to: i64,
    pub prize_type: TournamentPrizePrizeType,
    pub amount: f64,
    pub description: Option<String>,
    pub packs_count: Option<i64>,
    pub season_points: i64,
    pub tournament_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct TournamentPrizeUpdateRequest {
    pub placement_from: Option<i64>,
    pub placement_to: Option<i64>,
    pub prize_type: Option<TournamentPrizePrizeType>,
    pub amount: Option<f64>,
    pub description: Option<String>,
    pub packs_count: Option<i64>,
    pub season_points: Option<i64>,
    pub tournament_id: Option<i64>,
}
