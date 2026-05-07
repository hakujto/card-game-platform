<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeTransaction;
use App\Repository\Marketplace\TradeTransactionRepository;

class TradeTransactionService
{
    public function __construct(
        private TradeTransactionRepository $repository,
    ) {}

    public function create(array $data): TradeTransaction
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeTransaction $entity, array $data): TradeTransaction
    {
        throw new \LogicException('Not implemented');
    }
}
