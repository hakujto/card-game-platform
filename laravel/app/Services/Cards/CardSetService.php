<?php

namespace App\Services\Cards;

use App\Models\Cards\CardSet;

class CardSetService
{
    public function create(array $data): CardSet
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardSet $cardSet, array $data): CardSet
    {
        throw new \LogicException('Not implemented');
    }
    public function isLegalInStandard(int $id): bool
    {
        $cardSet = CardSet::findOrFail($id);
        $result = $cardSet->isLegalInStandard();
        $cardSet->save();
        return $result;
    }

    public function isLegalInFormat(int $id): bool
    {
        $cardSet = CardSet::findOrFail($id);
        $result = $cardSet->isLegalInFormat($format);
        $cardSet->save();
        return $result;
    }

    public function cardCountByRarity(int $id): int
    {
        $cardSet = CardSet::findOrFail($id);
        $result = $cardSet->cardCountByRarity($rarity);
        $cardSet->save();
        return $result;
    }

    public function rotateOut(int $id): void
    {
        $cardSet = CardSet::findOrFail($id);
        $cardSet->rotateOut();
        $cardSet->save();
    }
}
