module cards_project.marketplace.TradeTransactionEvents

// Domain events for TradeTransaction

[<CLIMutable>]
type TransactionCompleted = {
    transaction_id: int
    buyer_id: int
    seller_id: int
    final_price: decimal
    completed_at: string
}
