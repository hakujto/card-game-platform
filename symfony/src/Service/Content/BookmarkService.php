<?php

namespace App\Service\Content;

use App\Entity\Content\Bookmark;
use App\Repository\Content\BookmarkRepository;

class BookmarkService
{
    public function __construct(
        private BookmarkRepository $repository,
    ) {}

    public function create(array $data): Bookmark
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Bookmark $entity, array $data): Bookmark
    {
        throw new \LogicException('Not implemented');
    }
}
