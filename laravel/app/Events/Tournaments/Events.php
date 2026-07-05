<?php

namespace App\Events\Tournaments;

use Carbon\Carbon;

readonly class TournamentCompleted
{
    public function __construct(
        public readonly int $tournament_id,
        public readonly int $season_id,
        public readonly \Carbon\Carbon $completed_at,
    ) {}
}

readonly class PlayerRegistered
{
    public function __construct(
        public readonly int $tournament_id,
        public readonly int $player_id,
        public readonly \Carbon\Carbon $registered_at,
    ) {}
}
