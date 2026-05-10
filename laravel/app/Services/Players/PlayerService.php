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
}
