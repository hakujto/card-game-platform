<?php

namespace App\Service\Content;

use App\Entity\Content\ArticleTag;
use App\Repository\Content\ArticleTagRepository;

class ArticleTagService
{
    public function __construct(
        private ArticleTagRepository $repository,
    ) {}

    public function create(array $data): ArticleTag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleTag $entity, array $data): ArticleTag
    {
        throw new \LogicException('Not implemented');
    }

    public function rename(int $id, $newName): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('ArticleTag not found: ' . $id);
        $entity->rename($newName);
        $this->repository->save($entity, flush: true);
    }

    public function articleCount(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('ArticleTag not found: ' . $id);
        $result = $entity->articleCount();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
