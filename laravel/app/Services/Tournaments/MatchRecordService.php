<?php

namespace App\Services\Tournaments;

use App\Models\Tournaments\MatchRecord;

class MatchRecordService
{
    public function create(array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }

    public function update(MatchRecord $matchRecord, array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }
    public function recordResult(int $id, $p1_wins, $p2_wins): void
    {
        $matchRecord = MatchRecord::findOrFail($id);
        $matchRecord->recordResult($p1_wins, $p2_wins);
        $matchRecord->determineWinner(); // @after
        $matchRecord->save();
    }

    public function determineWinner(int $id): bool
    {
        $matchRecord = MatchRecord::findOrFail($id);
        $result = $matchRecord->determineWinner();
        $matchRecord->save();
        return $result;
    }

    public function concede(int $id, $player_id): void
    {
        $matchRecord = MatchRecord::findOrFail($id);
        $matchRecord->concede($player_id);
        $matchRecord->save();
    }

    public function draw(int $id): void
    {
        $matchRecord = MatchRecord::findOrFail($id);
        $matchRecord->draw();
        $matchRecord->save();
    }
}
