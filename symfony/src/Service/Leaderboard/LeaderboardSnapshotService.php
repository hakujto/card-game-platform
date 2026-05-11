<?php

namespace App\Service\Leaderboard;

use App\Entity\Leaderboard\LeaderboardSnapshot;
use App\Repository\Leaderboard\LeaderboardSnapshotRepository;

class LeaderboardSnapshotService
{
    public function __construct(
        private LeaderboardSnapshotRepository $repository,
    ) {}

    public function create(array $data): LeaderboardSnapshot
    {
        throw new \LogicException('Not implemented');
    }

    public function update(LeaderboardSnapshot $entity, array $data): LeaderboardSnapshot
    {
        throw new \LogicException('Not implemented');
    }
}
