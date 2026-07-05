<?php

namespace App\Events\Marketplace;

use Carbon\Carbon;

readonly class OrderPaid
{
    public function __construct(
        public readonly int $order_id,
        public readonly int $player_id,
        public readonly string $total,
        public readonly string $payment_method,
        public readonly \Carbon\Carbon $paid_at,
    ) {}
}

readonly class OrderShipped
{
    public function __construct(
        public readonly int $order_id,
        public readonly string $tracking_number,
        public readonly \Carbon\Carbon $shipped_at,
    ) {}
}

readonly class OrderRefunded
{
    public function __construct(
        public readonly int $order_id,
        public readonly \Carbon\Carbon $refunded_at,
    ) {}
}

readonly class TransactionCompleted
{
    public function __construct(
        public readonly int $transaction_id,
        public readonly int $buyer_id,
        public readonly int $seller_id,
        public readonly string $final_price,
        public readonly \Carbon\Carbon $completed_at,
    ) {}
}
