<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\Tournament;

class TournamentService
{
    public function create(array $data): Tournament
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Tournament $tournament, array $data): Tournament
    {
        throw new \LogicException('Not implemented');
    }
    public function start(int $id): void
    {
        $tournament = Tournament::findOrFail($id);
        $tournament->start();
        $tournament->save();
    }

    public function cancel(int $id): void
    {
        $tournament = Tournament::findOrFail($id);
        $tournament->cancel();
        $tournament->save();
    }

    public function complete(int $id): void
    {
        $tournament = Tournament::findOrFail($id);
        $tournament->complete();
        $tournament->save();
    }

    public function generateRound(int $id): void
    {
        $tournament = Tournament::findOrFail($id);
        $tournament->generateRound();
        $tournament->save();
    }

    public function calculatePrizeDistribution(int $id): string
    {
        $tournament = Tournament::findOrFail($id);
        $result = $tournament->calculatePrizeDistribution();
        $tournament->save();
        return $result;
    }

    public function registerPlayer(int $id, $player_id, $deck_id): void
    {
        $tournament = Tournament::findOrFail($id);
        $tournament->registerPlayer($player_id, $deck_id);
        $tournament->save();
    }

    public function isFull(int $id): bool
    {
        $tournament = Tournament::findOrFail($id);
        $result = $tournament->isFull();
        $tournament->save();
        return $result;
    }
}
