// Domain events for marketplace

pub const OrderPaid = struct {
    order_id: i64,
    player_id: i64,
    total: f64,
    payment_method: []const u8,
    paid_at: []const u8,
};

pub const OrderShipped = struct {
    order_id: i64,
    tracking_number: []const u8,
    shipped_at: []const u8,
};

pub const OrderRefunded = struct {
    order_id: i64,
    refunded_at: []const u8,
};

pub const TransactionCompleted = struct {
    transaction_id: i64,
    buyer_id: i64,
    seller_id: i64,
    final_price: f64,
    completed_at: []const u8,
};
