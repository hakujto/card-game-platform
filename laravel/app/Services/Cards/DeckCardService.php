<?php

namespace App\Services\Cards;

use App\Models\Cards\DeckCard;

class DeckCardService
{
    public function create(array $data): DeckCard
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckCard $deckCard, array $data): DeckCard
    {
        throw new \LogicException('Not implemented');
    }
    public function incrementAction(int $id, $amount): void
    {
        $deckCard = DeckCard::findOrFail($id);
        $deckCard->incrementAction($amount);
        $deckCard->save();
    }

    public function decrementAction(int $id, $amount): void
    {
        $deckCard = DeckCard::findOrFail($id);
        $deckCard->decrementAction($amount);
        $deckCard->save();
    }
}
