<?php

namespace App\Services\Content;

use App\Models\Content\DraftSession;

class DraftSessionService
{
    public function create(array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftSession $draftSession, array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }
    public function start(int $id): void
    {
        $draftSession = DraftSession::findOrFail($id);
        $draftSession->start();
        $draftSession->save();
    }

    public function abandon(int $id): void
    {
        $draftSession = DraftSession::findOrFail($id);
        $draftSession->abandon();
        $draftSession->save();
    }

    public function complete(int $id): void
    {
        $draftSession = DraftSession::findOrFail($id);
        $draftSession->complete();
        $draftSession->save();
    }

    public function isFull(int $id): bool
    {
        $draftSession = DraftSession::findOrFail($id);
        $result = $draftSession->isFull();
        $draftSession->save();
        return $result;
    }
}
