<?php

namespace App\Service\Content;

use App\Entity\Content\DraftSession;
use App\Repository\Content\DraftSessionRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class DraftSessionService
{
    public function __construct(
        private DraftSessionRepository $repository,
    ) {}

    public function create(array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftSession $entity, array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }

    public function start(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $entity->start();
        $this->repository->save($entity, flush: true);
    }

    public function abandon(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $entity->abandon();
        $this->repository->save($entity, flush: true);
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }

    public function isFull(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('DraftSession not found: ' . $id);
        $result = $entity->isFull();
        $this->repository->save($entity, flush: true);
        return $result;
    }
    public function transitionWaitingForPlayersToDrafting(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Drafting');

        $entity->setStatus('Drafting');
        $entity->start(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionDraftingToCompleted(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Completed');

        $entity->setStatus('Completed');
        $entity->complete(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_ADMIN'])]
    public function transitionDraftingToAbandoned(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Abandoned');

        $entity->setStatus('Abandoned');
        $entity->abandon(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_ADMIN'])]
    public function transitionWaitingForPlayersToAbandoned(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Abandoned');

        $entity->setStatus('Abandoned');
        $entity->abandon(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionCompletedToDrafting(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Completed -> Drafting is not allowed');
    }

    public function transitionAbandonedToDrafting(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Abandoned -> Drafting is not allowed');
    }
}
