<?php

namespace App\Services\Cards;

use App\Models\Cards\DeckTag;

class DeckTagService
{
    public function create(array $data): DeckTag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckTag $deckTag, array $data): DeckTag
    {
        throw new \LogicException('Not implemented');
    }
    public function mergeInto(int $id, $target_tag_id): void
    {
        $deckTag = DeckTag::findOrFail($id);
        $deckTag->mergeInto($target_tag_id);
        $deckTag->save();
    }
}
