<?php

namespace App\Listeners\Players;

class on_tournament_completed
{
    // Listens to: TournamentCompleted
    // Action:     sync_season_stats
    public function handle(object $event): void
    {
        // TODO: implement sync_season_stats
        throw new \RuntimeException('Not implemented');
    }
}

class on_player_registered
{
    // Listens to: PlayerRegistered
    // Action:     update_registration_count
    public function handle(object $event): void
    {
        // TODO: implement update_registration_count
        throw new \RuntimeException('Not implemented');
    }
}
