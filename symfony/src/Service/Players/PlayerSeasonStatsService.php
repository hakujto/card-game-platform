<?php

namespace App\Service\Players;

use App\Entity\Players\PlayerSeasonStats;
use App\Repository\Players\PlayerSeasonStatsRepository;

class PlayerSeasonStatsService
{
    public function __construct(
        private PlayerSeasonStatsRepository $repository,
    ) {}

    public function create(array $data): PlayerSeasonStats
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerSeasonStats $entity, array $data): PlayerSeasonStats
    {
        throw new \LogicException('Not implemented');
    }
}
