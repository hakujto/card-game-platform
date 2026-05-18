<?php

namespace App\Services\Cards;

use App\Models\Cards\DeckSideboardCard;

class DeckSideboardCardService
{
    public function create(array $data): DeckSideboardCard
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckSideboardCard $deckSideboardCard, array $data): DeckSideboardCard
    {
        throw new \LogicException('Not implemented');
    }
    public function incrementAction(int $id, $amount): void
    {
        $deckSideboardCard = DeckSideboardCard::findOrFail($id);
        $deckSideboardCard->incrementAction($amount);
        $deckSideboardCard->save();
    }

    public function decrementAction(int $id, $amount): void
    {
        $deckSideboardCard = DeckSideboardCard::findOrFail($id);
        $deckSideboardCard->decrementAction($amount);
        $deckSideboardCard->save();
    }
}
