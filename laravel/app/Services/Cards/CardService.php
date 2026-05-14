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
    public function ban(int $id): void
    {
        $card = Card::findOrFail($id);
        $card->ban();
        $card->save();
    }

    public function unban(int $id): void
    {
        $card = Card::findOrFail($id);
        $card->unban();
        $card->save();
    }

    public function restrict(int $id): void
    {
        $card = Card::findOrFail($id);
        $card->restrict();
        $card->save();
    }

    public function unrestrict(int $id): void
    {
        $card = Card::findOrFail($id);
        $card->unrestrict();
        $card->save();
    }

    public function calculateValue(int $id): string
    {
        $card = Card::findOrFail($id);
        $result = $card->calculateValue();
        $card->save();
        return $result;
    }
}
