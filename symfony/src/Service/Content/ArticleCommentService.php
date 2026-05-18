<?php

namespace App\Service\Content;

use App\Entity\Content\ArticleComment;
use App\Repository\Content\ArticleCommentRepository;

class ArticleCommentService
{
    public function __construct(
        private ArticleCommentRepository $repository,
    ) {}

    public function create(array $data): ArticleComment
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleComment $entity, array $data): ArticleComment
    {
        throw new \LogicException('Not implemented');
    }

    public function hide(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('ArticleComment not found: ' . $id);
        $entity->hide();
        $this->repository->save($entity, flush: true);
    }

    public function unhide(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('ArticleComment not found: ' . $id);
        $entity->unhide();
        $this->repository->save($entity, flush: true);
    }

    public function isReply(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('ArticleComment not found: ' . $id);
        $result = $entity->isReply();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
