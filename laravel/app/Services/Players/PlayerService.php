<?php

namespace App\Services\Players;

use App\Models\Players\Player;

class PlayerService
{
    public function create(array $data): Player
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Player $player, array $data): Player
    {
        throw new \LogicException('Not implemented');
    }
    public function promote(int $id): bool
    {
        $player = Player::findOrFail($id);
        $result = $player->promote();
        $player->save();
        return $result;
    }

    public function demote(int $id): bool
    {
        $player = Player::findOrFail($id);
        $result = $player->demote();
        $player->save();
        return $result;
    }

    public function recordWin(int $id): void
    {
        $player = Player::findOrFail($id);
        $player->recordWin();
        $player->save();
    }

    public function recordLoss(int $id): void
    {
        $player = Player::findOrFail($id);
        $player->recordLoss();
        $player->save();
    }

    public function winRate(int $id): string
    {
        $player = Player::findOrFail($id);
        $result = $player->winRate();
        $player->save();
        return $result;
    }

    public function verify(int $id): void
    {
        $player = Player::findOrFail($id);
        $player->verify();
        $player->save();
    }

    public function updateRating(int $id, $delta): void
    {
        $player = Player::findOrFail($id);
        $player->updateRating($delta);
        $player->save();
    }
}
