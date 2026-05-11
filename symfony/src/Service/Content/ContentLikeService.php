<?php

namespace App\Service\Content;

use App\Entity\Content\ContentLike;
use App\Repository\Content\ContentLikeRepository;

class ContentLikeService
{
    public function __construct(
        private ContentLikeRepository $repository,
    ) {}

    public function create(array $data): ContentLike
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ContentLike $entity, array $data): ContentLike
    {
        throw new \LogicException('Not implemented');
    }
}
