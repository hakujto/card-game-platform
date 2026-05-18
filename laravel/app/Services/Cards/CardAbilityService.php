<?php

namespace App\Services\Cards;

use App\Models\Cards\CardAbility;

class CardAbilityService
{
    public function create(array $data): CardAbility
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardAbility $cardAbility, array $data): CardAbility
    {
        throw new \LogicException('Not implemented');
    }
    public function isUsableAt(int $id): bool
    {
        $cardAbility = CardAbility::findOrFail($id);
        $result = $cardAbility->isUsableAt($timing);
        $cardAbility->save();
        return $result;
    }

    public function describe(int $id): string
    {
        $cardAbility = CardAbility::findOrFail($id);
        $result = $cardAbility->describe();
        $cardAbility->save();
        return $result;
    }
}
