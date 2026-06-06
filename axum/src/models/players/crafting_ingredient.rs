#[derive(Debug, Clone, sqlx::FromRow, serde::Serialize)]
pub struct CraftingIngredient {
    pub id: i64,
    pub created_at: String,
    pub updated_at: String,
    pub quantity: i64,
    pub recipe_id: i64,
    pub card_id: i64,
}

#[derive(Debug, serde::Deserialize)]
pub struct CraftingIngredientCreateRequest {
    pub quantity: i64,
    pub recipe_id: i64,
    pub card_id: i64,
}
