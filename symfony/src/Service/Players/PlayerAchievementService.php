<?php

namespace App\Service\Players;

use App\Entity\Players\PlayerAchievement;
use App\Repository\Players\PlayerAchievementRepository;

class PlayerAchievementService
{
    public function __construct(
        private PlayerAchievementRepository $repository,
    ) {}

    public function create(array $data): PlayerAchievement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerAchievement $entity, array $data): PlayerAchievement
    {
        throw new \LogicException('Not implemented');
    }

}
