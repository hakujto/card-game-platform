<?php

namespace App\Events\Tournaments;

class TournamentEvents {}

final class TournamentCompleted
{
    public function __construct(
        public readonly int $tournamentId,
        public readonly int $seasonId,
        public readonly \DateTimeInterface $completedAt
    ) {}
}

final class PlayerRegistered
{
    public function __construct(
        public readonly int $tournamentId,
        public readonly int $playerId,
        public readonly \DateTimeInterface $registeredAt
    ) {}
}
