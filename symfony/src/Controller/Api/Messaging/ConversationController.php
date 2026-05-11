<?php

namespace App\Controller\Api\Messaging;

use App\Entity\Messaging\Conversation;
use App\Repository\Messaging\ConversationRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Messaging\Message;
use App\Repository\Messaging\MessageRepository;

#[Route('/api/conversations', name: 'conversation_')]
class ConversationController extends AbstractController
{
    public function __construct(
        private ConversationRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private MessageRepository $messageRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['conversation:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $conversation = new Conversation();
        if (isset($data['createdAt'])) $conversation->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['lastMessageAt'])) $conversation->setLastMessageAt(new \DateTime($data['lastMessageAt']));
        if (isset($data['isArchivedByPlayer1'])) $conversation->setIsArchivedByPlayer1($data['isArchivedByPlayer1']);
        if (isset($data['isArchivedByPlayer2'])) $conversation->setIsArchivedByPlayer2($data['isArchivedByPlayer2']);
        if (!isset($data['player1'])) return $this->json(['error' => 'player1 is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player1 = $this->playerRepository->find($data['player1']);
        if (!$rel_player1) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $conversation->setPlayer1($rel_player1);
        if (!isset($data['player2'])) return $this->json(['error' => 'player2 is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player2 = $this->playerRepository->find($data['player2']);
        if (!$rel_player2) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $conversation->setPlayer2($rel_player2);
        if (!isset($data['messages'])) return $this->json(['error' => 'messages is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_messages = $this->messageRepository->find($data['messages']);
        if (!$rel_messages) return $this->json(['error' => 'Message not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $conversation->setMessages($rel_messages);

        $errors = $this->validator->validate($conversation);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($conversation, flush: true);
        return $this->json($conversation, Response::HTTP_CREATED, context: ['groups' => ['conversation:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Conversation $conversation): JsonResponse
    {
        return $this->json($conversation, context: ['groups' => ['conversation:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Conversation $conversation): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['createdAt'])) $conversation->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['lastMessageAt'])) $conversation->setLastMessageAt(new \DateTime($data['lastMessageAt']));
        if (isset($data['isArchivedByPlayer1'])) $conversation->setIsArchivedByPlayer1($data['isArchivedByPlayer1']);
        if (isset($data['isArchivedByPlayer2'])) $conversation->setIsArchivedByPlayer2($data['isArchivedByPlayer2']);
        if (isset($data['player1'])) {
            $rel_player1 = $this->playerRepository->find($data['player1']);
            if (!$rel_player1) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $conversation->setPlayer1($rel_player1);
        }
        if (isset($data['player2'])) {
            $rel_player2 = $this->playerRepository->find($data['player2']);
            if (!$rel_player2) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $conversation->setPlayer2($rel_player2);
        }
        if (isset($data['messages'])) {
            $rel_messages = $this->messageRepository->find($data['messages']);
            if (!$rel_messages) return $this->json(['error' => 'Message not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $conversation->setMessages($rel_messages);
        }

        $errors = $this->validator->validate($conversation);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($conversation, flush: true);
        return $this->json($conversation, context: ['groups' => ['conversation:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Conversation $conversation): JsonResponse
    {
        $this->repository->remove($conversation, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
