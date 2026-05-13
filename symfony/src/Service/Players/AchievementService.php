<?php

namespace App\Service\Players;

use App\Entity\Players\Achievement;
use App\Repository\Players\AchievementRepository;

class AchievementService
{
    public function __construct(
        private AchievementRepository $repository,
    ) {}

    public function create(array $data): Achievement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Achievement $entity, array $data): Achievement
    {
        throw new \LogicException('Not implemented');
    }

}
