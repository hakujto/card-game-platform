package model_marketplace

import (
	"cards_project/internal/types"
)

// Domain events emitted by TradeTransaction.
type TradeTransactionTransactionCompletedEvent struct {
	TransactionId int `json:"transaction_id"`
	BuyerId int `json:"buyer_id"`
	SellerId int `json:"seller_id"`
	FinalPrice types.Decimal `json:"final_price"`
	CompletedAt string `json:"completed_at"`
}
