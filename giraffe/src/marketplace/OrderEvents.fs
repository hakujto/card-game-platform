module cards_project.marketplace.OrderEvents

// Domain events for Order

[<CLIMutable>]
type OrderPaid = {
    order_id: int
    player_id: int
    total: decimal
    payment_method: string
    paid_at: string
}

[<CLIMutable>]
type OrderShipped = {
    order_id: int
    tracking_number: string
    shipped_at: string
}

[<CLIMutable>]
type OrderRefunded = {
    order_id: int
    refunded_at: string
}
