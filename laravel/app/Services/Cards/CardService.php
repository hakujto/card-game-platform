<?php

namespace App\Services\Cards;

use App\Models\Cards\Card;

class CardService
{
    public function create(array $data): Card
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Card $card, array $data): Card
    {
        throw new \LogicException('Not implemented');
    }
}
