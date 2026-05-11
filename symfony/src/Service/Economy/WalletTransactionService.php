<?php

namespace App\Service\Economy;

use App\Entity\Economy\WalletTransaction;
use App\Repository\Economy\WalletTransactionRepository;

class WalletTransactionService
{
    public function __construct(
        private WalletTransactionRepository $repository,
    ) {}

    public function create(array $data): WalletTransaction
    {
        throw new \LogicException('Not implemented');
    }

    public function update(WalletTransaction $entity, array $data): WalletTransaction
    {
        throw new \LogicException('Not implemented');
    }
}
