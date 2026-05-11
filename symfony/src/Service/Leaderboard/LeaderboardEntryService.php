<?php

namespace App\Service\Leaderboard;

use App\Entity\Leaderboard\LeaderboardEntry;
use App\Repository\Leaderboard\LeaderboardEntryRepository;

class LeaderboardEntryService
{
    public function __construct(
        private LeaderboardEntryRepository $repository,
    ) {}

    public function create(array $data): LeaderboardEntry
    {
        throw new \LogicException('Not implemented');
    }

    public function update(LeaderboardEntry $entity, array $data): LeaderboardEntry
    {
        throw new \LogicException('Not implemented');
    }
}
