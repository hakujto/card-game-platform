<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeDispute;
use App\Repository\Marketplace\TradeDisputeRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class TradeDisputeService
{
    public function __construct(
        private TradeDisputeRepository $repository,
    ) {}

    public function create(array $data): TradeDispute
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeDispute $entity, array $data): TradeDispute
    {
        throw new \LogicException('Not implemented');
    }

    public function escalate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->escalate();
        $this->repository->save($entity, flush: true);
    }

    public function resolve(int $id, $resolutionText): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->resolve($resolutionText);
        $this->repository->save($entity, flush: true);
    }

    public function closeResolved(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->closeResolved();
        $this->repository->save($entity, flush: true);
    }

    public function review(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->review();
        $this->repository->save($entity, flush: true);
    }
    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_ADMIN'])]
    public function transitionOpenToUnderReview(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'UnderReview');

        $entity->setStatus('UnderReview');
        $entity->review(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_ADMIN'])]
    public function transitionUnderReviewToResolved(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Resolved');
        if ($entity->getResolution() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('resolution is required for UnderReview -> Resolved');
        }

        $entity->setStatus('Resolved');
        $entity->closeResolved(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted('ROLE_ADMIN')]
    public function transitionUnderReviewToEscalated(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Escalated');

        $entity->setStatus('Escalated');
        $entity->escalate(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted('ROLE_ADMIN')]
    public function transitionEscalatedToResolved(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Resolved');
        if ($entity->getResolution() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('resolution is required for Escalated -> Resolved');
        }

        $entity->setStatus('Resolved');
        $entity->closeResolved(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionResolvedToOpen(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Resolved -> Open is not allowed');
    }
}
