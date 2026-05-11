<?php

namespace App\Service\Economy;

use App\Entity\Economy\Wallet;
use App\Repository\Economy\WalletRepository;

class WalletService
{
    public function __construct(
        private WalletRepository $repository,
    ) {}

    public function create(array $data): Wallet
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Wallet $entity, array $data): Wallet
    {
        throw new \LogicException('Not implemented');
    }
}
