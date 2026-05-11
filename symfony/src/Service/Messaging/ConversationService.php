<?php

namespace App\Service\Messaging;

use App\Entity\Messaging\Conversation;
use App\Repository\Messaging\ConversationRepository;

class ConversationService
{
    public function __construct(
        private ConversationRepository $repository,
    ) {}

    public function create(array $data): Conversation
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Conversation $entity, array $data): Conversation
    {
        throw new \LogicException('Not implemented');
    }
}
