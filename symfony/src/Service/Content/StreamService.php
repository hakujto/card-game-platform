<?php

namespace App\Service\Content;

use App\Entity\Content\Stream;
use App\Repository\Content\StreamRepository;

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
}
