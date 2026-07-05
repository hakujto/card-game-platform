<?php

namespace App\Events\Marketplace;

class TradeTransactionEvents {}

final class TransactionCompleted
{
    public function __construct(
        public readonly int $transactionId,
        public readonly int $buyerId,
        public readonly int $sellerId,
        public readonly string $finalPrice,
        public readonly \DateTimeInterface $completedAt
    ) {}
}
