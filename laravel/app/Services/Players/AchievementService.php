<?php

namespace App\Services\Players;

use App\Models\Players\Achievement;

class AchievementService
{
    public function create(array $data): Achievement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Achievement $achievement, array $data): Achievement
    {
        throw new \LogicException('Not implemented');
    }
    public function pointValue(int $id): int
    {
        $achievement = Achievement::findOrFail($id);
        $result = $achievement->pointValue($multiplier);
        $achievement->save();
        return $result;
    }

    public function reveal(int $id): void
    {
        $achievement = Achievement::findOrFail($id);
        $achievement->reveal();
        $achievement->save();
    }
}
