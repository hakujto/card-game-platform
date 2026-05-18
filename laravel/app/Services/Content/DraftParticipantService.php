<?php

namespace App\Services\Content;

use App\Models\Content\DraftParticipant;

class DraftParticipantService
{
    public function create(array $data): DraftParticipant
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftParticipant $draftParticipant, array $data): DraftParticipant
    {
        throw new \LogicException('Not implemented');
    }
    public function pickCard(int $id, $card_id, $pack_number): void
    {
        $draftParticipant = DraftParticipant::findOrFail($id);
        $draftParticipant->pickCard($card_id, $pack_number);
        $draftParticipant->save();
    }

    public function draftedCardCount(int $id): int
    {
        $draftParticipant = DraftParticipant::findOrFail($id);
        $result = $draftParticipant->draftedCardCount();
        $draftParticipant->save();
        return $result;
    }
}
