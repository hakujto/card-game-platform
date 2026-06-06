#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct CraftingRecipe {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub dust_cost: i64,
    #[serde(serialize_with = "crate::serde_utils::serialize_i64_as_bool")]
    pub is_available: i64,
    pub result_card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CraftingRecipeCreateRequest {
    pub dust_cost: i64,
    pub is_available: bool,
    pub result_card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CraftingRecipeUpdateRequest {
    pub dust_cost: Option<i64>,
    pub is_available: Option<bool>,
    pub result_card_id: Option<i64>,
}
