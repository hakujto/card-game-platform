<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\TournamentPrize;

class TournamentPrizeService
{
    public function create(array $data): TournamentPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentPrize $tournamentPrize, array $data): TournamentPrize
    {
        throw new \LogicException('Not implemented');
    }
    public function appliesToPlacement(int $id): bool
    {
        $tournamentPrize = TournamentPrize::findOrFail($id);
        $result = $tournamentPrize->appliesToPlacement($placement);
        $tournamentPrize->save();
        return $result;
    }

    public function awardToPlayer(int $id, $player_id): void
    {
        $tournamentPrize = TournamentPrize::findOrFail($id);
        $tournamentPrize->awardToPlayer($player_id);
        $tournamentPrize->save();
    }
}
