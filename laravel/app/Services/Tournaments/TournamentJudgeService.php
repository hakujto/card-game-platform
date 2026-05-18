<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\TournamentJudge;

class TournamentJudgeService
{
    public function create(array $data): TournamentJudge
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentJudge $tournamentJudge, array $data): TournamentJudge
    {
        throw new \LogicException('Not implemented');
    }
    public function promoteToHead(int $id): void
    {
        $tournamentJudge = TournamentJudge::findOrFail($id);
        $tournamentJudge->promoteToHead();
        $tournamentJudge->save();
    }

    public function remove(int $id): void
    {
        $tournamentJudge = TournamentJudge::findOrFail($id);
        $tournamentJudge->remove();
        $tournamentJudge->save();
    }
}
