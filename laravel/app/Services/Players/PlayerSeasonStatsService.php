<?php

namespace App\Services\Players;

use App\Models\Players\PlayerSeasonStats;

class PlayerSeasonStatsService
{
    public function create(array $data): PlayerSeasonStats
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerSeasonStats $playerSeasonStats, array $data): PlayerSeasonStats
    {
        throw new \LogicException('Not implemented');
    }
    public function winRate(int $id): string
    {
        $playerSeasonStats = PlayerSeasonStats::findOrFail($id);
        $result = $playerSeasonStats->winRate();
        $playerSeasonStats->save();
        return $result;
    }

    public function addPoints(int $id, $points): void
    {
        $playerSeasonStats = PlayerSeasonStats::findOrFail($id);
        $playerSeasonStats->addPoints($points);
        $playerSeasonStats->save();
    }

    public function recordTournamentWin(int $id): void
    {
        $playerSeasonStats = PlayerSeasonStats::findOrFail($id);
        $playerSeasonStats->recordTournamentWin();
        $playerSeasonStats->save();
    }
}
