<?php

namespace App\Service\Economy;

use App\Entity\Economy\TopUpPackage;
use App\Repository\Economy\TopUpPackageRepository;

class TopUpPackageService
{
    public function __construct(
        private TopUpPackageRepository $repository,
    ) {}

    public function create(array $data): TopUpPackage
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TopUpPackage $entity, array $data): TopUpPackage
    {
        throw new \LogicException('Not implemented');
    }
}
