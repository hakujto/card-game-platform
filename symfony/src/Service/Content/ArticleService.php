<?php

namespace App\Service\Content;

use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;

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

    public function incrementView(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Article not found: ' . $id);
        $entity->incrementView();
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
}
