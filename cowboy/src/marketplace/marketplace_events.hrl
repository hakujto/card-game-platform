%% Domain events for marketplace

%% Event emitted by Order
-record(orderpaid, {
    order_id :: integer(),
    player_id :: integer(),
    total :: float(),
    payment_method :: binary(),
    paid_at :: binary()
}).

%% Event emitted by Order
-record(ordershipped, {
    order_id :: integer(),
    tracking_number :: binary(),
    shipped_at :: binary()
}).

%% Event emitted by Order
-record(orderrefunded, {
    order_id :: integer(),
    refunded_at :: binary()
}).

%% Event emitted by TradeTransaction
-record(transactioncompleted, {
    transaction_id :: integer(),
    buyer_id :: integer(),
    seller_id :: integer(),
    final_price :: float(),
    completed_at :: binary()
}).
