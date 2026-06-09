use axum::{extract::{Path, Query, State}, http::StatusCode, Json};
use serde::Deserialize;
use sqlx::SqlitePool;
use crate::models::marketplace::trade_transaction::{TradeTransaction};

type AppState = SqlitePool;

#[derive(Deserialize)]
pub struct TradeTransactionListParams {
    pub skip: Option<i64>,
    pub limit: Option<i64>,
}

pub async fn list_trade_transaction(
    State(pool): State<AppState>,
    Query(params): Query<TradeTransactionListParams>,
) -> Result<Json<Vec<TradeTransaction>>, (StatusCode, String)> {
    let skip  = params.skip.unwrap_or(0);
    let limit = params.limit.unwrap_or(100).min(500);
    let rows = sqlx::query_as_unchecked!(TradeTransaction, "SELECT * FROM trade_transactions LIMIT $1 OFFSET $2", limit, skip)
        .fetch_all(&pool).await;
    rows.map(Json).map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))
}

pub async fn get_trade_transaction(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<Json<TradeTransaction>, (StatusCode, String)> {
    let row = sqlx::query_as_unchecked!(TradeTransaction, "SELECT * FROM trade_transactions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeTransaction not found".to_string()))?;
    Ok(Json(row))
}

pub async fn complete_trade_transaction(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeTransaction, "SELECT * FROM trade_transactions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeTransaction not found".to_string()))?;
    // TODO: implement complete business logic
    Ok(StatusCode::OK)
}

pub async fn refund_trade_transaction(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeTransaction, "SELECT * FROM trade_transactions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeTransaction not found".to_string()))?;
    // TODO: implement refund business logic
    Ok(StatusCode::OK)
}

pub async fn open_dispute_trade_transaction(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeTransaction, "SELECT * FROM trade_transactions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeTransaction not found".to_string()))?;
    // TODO: implement open_dispute business logic
    Ok(StatusCode::OK)
}

pub async fn seller_net_trade_transaction(
    State(pool): State<AppState>,
    Path(id): Path<i64>,
) -> Result<StatusCode, (StatusCode, String)> {
    let _row = sqlx::query_as_unchecked!(TradeTransaction, "SELECT * FROM trade_transactions WHERE id = $1", id)
        .fetch_optional(&pool).await
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .ok_or((StatusCode::NOT_FOUND, "TradeTransaction not found".to_string()))?;
    // TODO: implement seller_net business logic
    Ok(StatusCode::OK)
}

pub fn trade_transaction_router() -> axum::Router<AppState> {
    axum::Router::new()
        .route("/api/trade_transactions", axum::routing::get(list_trade_transaction))
        .route("/api/trade_transactions/:id", axum::routing::MethodRouter::new().get(get_trade_transaction))
        .route("/api/trade_transactions/:id/api/transactions/{id}/complete", axum::routing::post(complete_trade_transaction))
        .route("/api/trade_transactions/:id/api/transactions/{id}/refund", axum::routing::post(refund_trade_transaction))
        .route("/api/trade_transactions/:id/api/transactions/{id}/dispute", axum::routing::post(open_dispute_trade_transaction))
        .route("/api/trade_transactions/:id/api/transactions/{id}/seller-net", axum::routing::get(seller_net_trade_transaction))
}

#[cfg(test)]
mod tests {
    use super::*;
    use axum::body::Body;
    use axum::http::{Request, StatusCode};
    use tower::ServiceExt;
    use sqlx::SqlitePool;

    async fn setup_pool() -> SqlitePool {
        let pool = SqlitePool::connect(":memory:").await.unwrap();
        sqlx::migrate!("./migrations").run(&pool).await.unwrap();
        pool
    }

    fn app(pool: SqlitePool) -> axum::Router {
        trade_transaction_router().with_state(pool)
    }

    #[tokio::test]
    async fn test_list_trade_transaction() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_transactions").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn test_retrieve_trade_transaction() {
        let pool = setup_pool().await;
        let resp = app(pool).oneshot(
            Request::builder().uri("/api/trade_transactions/1").body(Body::empty()).unwrap()
        ).await.unwrap();
        assert!(resp.status() == StatusCode::NOT_FOUND || resp.status() == StatusCode::OK);
    }

}
