<?php

namespace App\Services\Players;

use App\Models\Players\PlayerAchievement;

class PlayerAchievementService
{
    public function create(array $data): PlayerAchievement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerAchievement $playerAchievement, array $data): PlayerAchievement
    {
        throw new \LogicException('Not implemented');
    }
    public function incrementProgress(int $id, $amount): void
    {
        $playerAchievement = PlayerAchievement::findOrFail($id);
        $playerAchievement->incrementProgress($amount);
        $playerAchievement->save();
    }

    public function complete(int $id): void
    {
        $playerAchievement = PlayerAchievement::findOrFail($id);
        $playerAchievement->complete();
        $playerAchievement->save();
    }

    // triggered by @on(is_completed = true)
    public function setIsCompleted(int $id, string $value): void
    {
        $playerAchievement = PlayerAchievement::findOrFail($id);
        $playerAchievement->is_completed = $value;
        if ($value === 'true') {
            $playerAchievement->complete();
        }
        $playerAchievement->save();
    }
}
