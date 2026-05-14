<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\TournamentRound;

class TournamentRoundService
{
    public function create(array $data): TournamentRound
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentRound $tournamentRound, array $data): TournamentRound
    {
        throw new \LogicException('Not implemented');
    }
    public function start(int $id): void
    {
        $tournamentRound = TournamentRound::findOrFail($id);
        $tournamentRound->start();
        $tournamentRound->save();
    }

    public function complete(int $id): void
    {
        $tournamentRound = TournamentRound::findOrFail($id);
        $tournamentRound->complete();
        $tournamentRound->save();
    }

    public function generatePairings(int $id): void
    {
        $tournamentRound = TournamentRound::findOrFail($id);
        $tournamentRound->generatePairings();
        $tournamentRound->save();
    }
}
