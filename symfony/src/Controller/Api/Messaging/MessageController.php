<?php

namespace App\Controller\Api\Messaging;

use App\Entity\Messaging\Message;
use App\Repository\Messaging\MessageRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Messaging\Conversation;
use App\Repository\Messaging\ConversationRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/messages', name: 'message_')]
class MessageController extends AbstractController
{
    public function __construct(
        private MessageRepository $repository,
        private ValidatorInterface $validator,
        private ConversationRepository $conversationRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['message:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $message = new Message();
        if (isset($data['body'])) $message->setBody($data['body']);
        if (isset($data['isRead'])) $message->setIsRead($data['isRead']);
        if (isset($data['readAt'])) $message->setReadAt(new \DateTime($data['readAt']));
        if (isset($data['isDeletedBySender'])) $message->setIsDeletedBySender($data['isDeletedBySender']);
        if (isset($data['isDeletedByReceiver'])) $message->setIsDeletedByReceiver($data['isDeletedByReceiver']);
        if (isset($data['createdAt'])) $message->setCreatedAt(new \DateTime($data['createdAt']));
        if (array_key_exists('conversation', $data)) {
            $message->setConversation($data['conversation'] !== null ? $this->conversationRepository->find($data['conversation']) : null);
        }
        if (!isset($data['sender'])) return $this->json(['error' => 'sender is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_sender = $this->playerRepository->find($data['sender']);
        if (!$rel_sender) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $message->setSender($rel_sender);

        $errors = $this->validator->validate($message);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($message, flush: true);
        return $this->json($message, Response::HTTP_CREATED, context: ['groups' => ['message:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Message $message): JsonResponse
    {
        return $this->json($message, context: ['groups' => ['message:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Message $message): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['body'])) $message->setBody($data['body']);
        if (isset($data['isRead'])) $message->setIsRead($data['isRead']);
        if (isset($data['readAt'])) $message->setReadAt(new \DateTime($data['readAt']));
        if (isset($data['isDeletedBySender'])) $message->setIsDeletedBySender($data['isDeletedBySender']);
        if (isset($data['isDeletedByReceiver'])) $message->setIsDeletedByReceiver($data['isDeletedByReceiver']);
        if (isset($data['createdAt'])) $message->setCreatedAt(new \DateTime($data['createdAt']));
        if (array_key_exists('conversation', $data)) {
            $message->setConversation($data['conversation'] !== null ? $this->conversationRepository->find($data['conversation']) : null);
        }
        if (isset($data['sender'])) {
            $rel_sender = $this->playerRepository->find($data['sender']);
            if (!$rel_sender) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $message->setSender($rel_sender);
        }

        $errors = $this->validator->validate($message);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($message, flush: true);
        return $this->json($message, context: ['groups' => ['message:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Message $message): JsonResponse
    {
        $this->repository->remove($message, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
