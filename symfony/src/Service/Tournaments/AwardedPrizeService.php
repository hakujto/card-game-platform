<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\AwardedPrize;
use App\Repository\Tournaments\AwardedPrizeRepository;

class AwardedPrizeService
{
    public function __construct(
        private AwardedPrizeRepository $repository,
    ) {}

    public function create(array $data): AwardedPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function update(AwardedPrize $entity, array $data): AwardedPrize
    {
        throw new \LogicException('Not implemented');
    }
}
