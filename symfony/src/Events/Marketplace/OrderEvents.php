<?php

namespace App\Events\Marketplace;

class OrderEvents {}

final class OrderPaid
{
    public function __construct(
        public readonly int $orderId,
        public readonly int $playerId,
        public readonly string $total,
        public readonly string $paymentMethod,
        public readonly \DateTimeInterface $paidAt
    ) {}
}

final class OrderShipped
{
    public function __construct(
        public readonly int $orderId,
        public readonly string $trackingNumber,
        public readonly \DateTimeInterface $shippedAt
    ) {}
}

final class OrderRefunded
{
    public function __construct(
        public readonly int $orderId,
        public readonly \DateTimeInterface $refundedAt
    ) {}
}
