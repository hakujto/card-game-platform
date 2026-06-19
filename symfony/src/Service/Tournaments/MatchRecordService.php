<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\MatchRecord;
use App\Repository\Tournaments\MatchRecordRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class MatchRecordService
{
    public function __construct(
        private MatchRecordRepository $repository,
    ) {}

    public function create(array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }

    public function update(MatchRecord $entity, array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }

    public function recordResult(int $id, $p1Wins, $p2Wins): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $entity->recordResult($p1Wins, $p2Wins);
        $entity->determineWinner(); // @after
        $this->repository->save($entity, flush: true);
    }

    public function finalizeResult(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $entity->finalizeResult();
        $entity->determineWinner(); // @after
        $this->repository->save($entity, flush: true);
    }

    public function determineWinner(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $result = $entity->determineWinner();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function concede(int $id, $playerId): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        if (!($entity->getStatus() === 'Active'))
            throw new \RuntimeException('Guard condition not met for concede');
        $entity->concede($playerId);
        $this->repository->save($entity, flush: true);
    }

    public function draw(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('MatchRecord not found: ' . $id);
        $entity->draw();
        $this->repository->save($entity, flush: true);
    }
    public function transitionPendingToActive(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Active');

        $entity->setStatus('Active');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionActiveToCompleted(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Completed');

        $entity->setStatus('Completed');
        $entity->finalizeResult(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionActiveToDraw(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Draw');

        $entity->setStatus('Draw');
        $entity->draw(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionPendingToBYE(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'BYE');

        $entity->setStatus('BYE');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionCompletedToActive(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Completed -> Active is not allowed');
    }

    public function transitionDrawToActive(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Draw -> Active is not allowed');
    }

    public function transitionBYEToActive(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition BYE -> Active is not allowed');
    }
}
