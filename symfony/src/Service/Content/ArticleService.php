<?php

namespace App\Service\Content;

use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException;

class ArticleService
{
    public function __construct(
        private ArticleRepository $repository,
    ) {}

    public function create(array $data): Article
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Article $entity, array $data): Article
    {
        throw new \LogicException('Not implemented');
    }

    public function publish(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $entity->publish();
        $this->repository->save($entity, flush: true);
    }

    public function archive(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $entity->archive();
        $this->repository->save($entity, flush: true);
    }

    public function replace(int $id, $data): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $result = $entity->replace($data);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function incrementView(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $entity->incrementView();
        $this->repository->save($entity, flush: true);
    }

    public function like(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $entity->like();
        $this->repository->save($entity, flush: true);
    }

    public function unlike(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $entity->unlike();
        $this->repository->save($entity, flush: true);
    }

    public function readingTimeMinutes(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $result = $entity->readingTimeMinutes();
        $this->repository->save($entity, flush: true);
        return $result;
    }
    public function transitionDraftToPublished(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Published');
        if ($entity->getTitle() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('title is required for Draft -> Published');
        }
        if ($entity->getBody() === null) {
            throw new \Symfony\Component\HttpKernel\Exception\UnprocessableEntityHttpException('body is required for Draft -> Published');
        }

        $entity->setStatus('Published');
        $entity->publish(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionPublishedToArchived(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Archived');

        $entity->setStatus('Archived');
        $entity->archive(); // @after

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionArchivedToDraft(int $id): object
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \Symfony\Component\HttpKernel\Exception\NotFoundHttpException();

        $entity->assertTransition($entity->getStatus(), 'Draft');

        $entity->setStatus('Draft');

        $this->repository->save($entity, flush: true);
        return $entity;
    }

    public function transitionPublishedToDraft(int $id): never
    {
        throw new \Symfony\Component\HttpKernel\Exception\ConflictHttpException('Transition Published -> Draft is not allowed');
    }
}
