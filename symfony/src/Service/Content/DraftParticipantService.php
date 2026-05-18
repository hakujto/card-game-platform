<?php

namespace App\Service\Content;

use App\Entity\Content\DraftParticipant;
use App\Repository\Content\DraftParticipantRepository;

class DraftParticipantService
{
    public function __construct(
        private DraftParticipantRepository $repository,
    ) {}

    public function create(array $data): DraftParticipant
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftParticipant $entity, array $data): DraftParticipant
    {
        throw new \LogicException('Not implemented');
    }

    public function pickCard(int $id, $cardId, $packNumber): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftParticipant not found: ' . $id);
        $entity->pickCard($cardId, $packNumber);
        $this->repository->save($entity, flush: true);
    }

    public function draftedCardCount(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftParticipant not found: ' . $id);
        $result = $entity->draftedCardCount();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
