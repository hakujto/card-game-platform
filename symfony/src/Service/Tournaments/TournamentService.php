<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class TournamentService
{
    public function __construct(
        private TournamentRepository $repository,
    ) {}

    public function create(array $data): Tournament
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Tournament $entity, array $data): Tournament
    {
        throw new \LogicException('Not implemented');
    }

    public function start(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->start();
        $this->repository->save($entity, flush: true);
    }

    public function cancel(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->cancel();
        $this->repository->save($entity, flush: true);
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }

    public function generateRound(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->generateRound();
        $this->repository->save($entity, flush: true);
    }

    public function calculatePrizeDistribution(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $result = $entity->calculatePrizeDistribution();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function registerPlayer(int $id, $playerId, $deckId): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->registerPlayer($playerId, $deckId);
        $this->repository->save($entity, flush: true);
    }

    public function isFull(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $result = $entity->isFull();
        $this->repository->save($entity, flush: true);
        return $result;
    }
    public function transitionDraftToRegistration(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Registration');
        if ($entity->getName() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('name is required for Draft -> Registration');
        }
        if ($entity->getStartTime() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('start_time is required for Draft -> Registration');
        }

        $entity->setStatus('Registration');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionRegistrationToOngoing(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Ongoing');

        $entity->setStatus('Ongoing');
        $entity->start(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionRegistrationToCancelled(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Cancelled');

        $entity->setStatus('Cancelled');
        $entity->cancel(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionOngoingToCompleted(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Completed');

        $entity->setStatus('Completed');
        $entity->complete(); // @after
        $entity->calculatePrizeDistribution(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionOngoingToCancelled(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Cancelled');

        $entity->setStatus('Cancelled');
        $entity->cancel(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionCompletedToDraft(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Completed -> Draft is not allowed');
    }

    public function transitionCancelledToDraft(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Cancelled -> Draft is not allowed');
    }
}
