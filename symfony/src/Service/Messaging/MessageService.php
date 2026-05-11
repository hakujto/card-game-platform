<?php

namespace App\Service\Messaging;

use App\Entity\Messaging\Message;
use App\Repository\Messaging\MessageRepository;

class MessageService
{
    public function __construct(
        private MessageRepository $repository,
    ) {}

    public function create(array $data): Message
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Message $entity, array $data): Message
    {
        throw new \LogicException('Not implemented');
    }
}
