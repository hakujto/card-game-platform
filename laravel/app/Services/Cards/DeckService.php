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
    public function validateSize(int $id): bool
    {
        $deck = Deck::findOrFail($id);
        $result = $deck->validateSize();
        $deck->save();
        return $result;
    }

    public function addCard(int $id, $card_id, $quantity): void
    {
        $deck = Deck::findOrFail($id);
        $deck->addCard($card_id, $quantity);
        $deck->save();
    }

    public function removeCard(int $id): void
    {
        $deck = Deck::findOrFail($id);
        $deck->removeCard($card_id);
        $deck->save();
    }

    public function winRate(int $id): string
    {
        $deck = Deck::findOrFail($id);
        $result = $deck->winRate();
        $deck->save();
        return $result;
    }

    public function clone(int $id): mixed
    {
        $deck = Deck::findOrFail($id);
        $result = $deck->clone();
        $deck->save();
        return $result;
    }

    public function publish(int $id): void
    {
        $deck = Deck::findOrFail($id);
        $deck->publish();
        $deck->save();
    }

    public function unpublish(int $id): void
    {
        $deck = Deck::findOrFail($id);
        $deck->unpublish();
        $deck->save();
    }

    public function certifyTournamentLegal(int $id): bool
    {
        $deck = Deck::findOrFail($id);
        $result = $deck->certifyTournamentLegal();
        $deck->save();
        return $result;
    }
}
