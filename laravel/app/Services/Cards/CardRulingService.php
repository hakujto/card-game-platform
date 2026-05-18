<?php

namespace App\Services\Cards;

use App\Models\Cards\CardRuling;

class CardRulingService
{
    public function create(array $data): CardRuling
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardRuling $cardRuling, array $data): CardRuling
    {
        throw new \LogicException('Not implemented');
    }
    public function isCurrent(int $id): bool
    {
        $cardRuling = CardRuling::findOrFail($id);
        $result = $cardRuling->isCurrent();
        $cardRuling->save();
        return $result;
    }

    public function supersedesPrevious(int $id): bool
    {
        $cardRuling = CardRuling::findOrFail($id);
        $result = $cardRuling->supersedesPrevious();
        $cardRuling->save();
        return $result;
    }
}
