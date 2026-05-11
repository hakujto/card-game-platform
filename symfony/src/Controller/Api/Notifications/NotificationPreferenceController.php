<?php

namespace App\Controller\Api\Notifications;

use App\Entity\Notifications\NotificationPreference;
use App\Repository\Notifications\NotificationPreferenceRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/notification_preferences', name: 'notificationPreference_')]
class NotificationPreferenceController extends AbstractController
{
    public function __construct(
        private NotificationPreferenceRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['notificationPreference:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $notificationPreference = new NotificationPreference();
        if (isset($data['notificationType'])) $notificationPreference->setNotificationType($data['notificationType']);
        if (isset($data['emailEnabled'])) $notificationPreference->setEmailEnabled($data['emailEnabled']);
        if (isset($data['pushEnabled'])) $notificationPreference->setPushEnabled($data['pushEnabled']);
        if (isset($data['inAppEnabled'])) $notificationPreference->setInAppEnabled($data['inAppEnabled']);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $notificationPreference->setPlayer($rel_player);

        $errors = $this->validator->validate($notificationPreference);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($notificationPreference, flush: true);
        return $this->json($notificationPreference, Response::HTTP_CREATED, context: ['groups' => ['notificationPreference:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(NotificationPreference $notificationPreference): JsonResponse
    {
        return $this->json($notificationPreference, context: ['groups' => ['notificationPreference:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, NotificationPreference $notificationPreference): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['notificationType'])) $notificationPreference->setNotificationType($data['notificationType']);
        if (isset($data['emailEnabled'])) $notificationPreference->setEmailEnabled($data['emailEnabled']);
        if (isset($data['pushEnabled'])) $notificationPreference->setPushEnabled($data['pushEnabled']);
        if (isset($data['inAppEnabled'])) $notificationPreference->setInAppEnabled($data['inAppEnabled']);
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $notificationPreference->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($notificationPreference);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($notificationPreference, flush: true);
        return $this->json($notificationPreference, context: ['groups' => ['notificationPreference:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(NotificationPreference $notificationPreference): JsonResponse
    {
        $this->repository->remove($notificationPreference, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
