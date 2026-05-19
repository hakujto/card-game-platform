<?php

namespace App\Service\Content;

use App\Entity\Content\Stream;
use App\Repository\Content\StreamRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class StreamService
{
    public function __construct(
        private StreamRepository $repository,
    ) {}

    public function create(array $data): Stream
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Stream $entity, array $data): Stream
    {
        throw new \LogicException('Not implemented');
    }

    public function goLive(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $entity->goLive();
        $this->repository->save($entity, flush: true);
    }

    public function end(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $entity->end();
        $this->repository->save($entity, flush: true);
    }

    public function updateViewerPeak(int $id, $count): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $entity->updateViewerPeak($count);
        $this->repository->save($entity, flush: true);
    }

    public function durationMinutes(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Stream not found: ' . $id);
        $result = $entity->durationMinutes();
        $this->repository->save($entity, flush: true);
        return $result;
    }
    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_STREAMER'])]
    public function transitionScheduledToLive(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Live');
        if ($entity->getStreamUrl() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('stream_url is required for Scheduled -> Live');
        }

        $entity->setStatus('Live');
        $entity->goLive(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    #[\Symfony\Component\Security\Http\Attribute\IsGranted(['ROLE_STREAMER'])]
    public function transitionLiveToEnded(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Ended');

        $entity->setStatus('Ended');
        $entity->end(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionEndedToLive(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Ended -> Live is not allowed');
    }
}
