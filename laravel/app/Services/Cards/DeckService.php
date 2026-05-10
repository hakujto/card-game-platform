<?php

namespace App\Services\Cards;

use App\Models\Cards\Deck;

class DeckService
{
    public function create(array $data): Deck
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Deck $deck, array $data): Deck
    {
        throw new \LogicException('Not implemented');
    }
}
