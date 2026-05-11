<?php

namespace App\Controller\Api\Notifications;

use App\Entity\Notifications\Notification;
use App\Repository\Notifications\NotificationRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/notifications', name: 'notification_')]
class NotificationController extends AbstractController
{
    public function __construct(
        private NotificationRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['notification:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $notification = new Notification();
        if (isset($data['notificationType'])) $notification->setNotificationType($data['notificationType']);
        if (isset($data['title'])) $notification->setTitle($data['title']);
        if (isset($data['body'])) $notification->setBody($data['body']);
        if (isset($data['isRead'])) $notification->setIsRead($data['isRead']);
        if (isset($data['readAt'])) $notification->setReadAt(new \DateTime($data['readAt']));
        if (isset($data['actionUrl'])) $notification->setActionUrl($data['actionUrl']);
        if (isset($data['createdAt'])) $notification->setCreatedAt(new \DateTime($data['createdAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $notification->setPlayer($rel_player);

        $errors = $this->validator->validate($notification);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($notification, flush: true);
        return $this->json($notification, Response::HTTP_CREATED, context: ['groups' => ['notification:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Notification $notification): JsonResponse
    {
        return $this->json($notification, context: ['groups' => ['notification:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Notification $notification): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['notificationType'])) $notification->setNotificationType($data['notificationType']);
        if (isset($data['title'])) $notification->setTitle($data['title']);
        if (isset($data['body'])) $notification->setBody($data['body']);
        if (isset($data['isRead'])) $notification->setIsRead($data['isRead']);
        if (isset($data['readAt'])) $notification->setReadAt(new \DateTime($data['readAt']));
        if (isset($data['actionUrl'])) $notification->setActionUrl($data['actionUrl']);
        if (isset($data['createdAt'])) $notification->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $notification->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($notification);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($notification, flush: true);
        return $this->json($notification, context: ['groups' => ['notification:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Notification $notification): JsonResponse
    {
        $this->repository->remove($notification, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
