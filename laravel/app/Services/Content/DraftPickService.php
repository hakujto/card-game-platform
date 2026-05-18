<?php

namespace App\Services\Content;

use App\Models\Content\DraftPick;

class DraftPickService
{
    public function create(array $data): DraftPick
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftPick $draftPick, array $data): DraftPick
    {
        throw new \LogicException('Not implemented');
    }
    public function isFirstPick(int $id): bool
    {
        $draftPick = DraftPick::findOrFail($id);
        $result = $draftPick->isFirstPick();
        $draftPick->save();
        return $result;
    }
}
