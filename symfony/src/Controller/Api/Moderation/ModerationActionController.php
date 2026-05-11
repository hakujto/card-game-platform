<?php

namespace App\Controller\Api\Moderation;

use App\Entity\Moderation\ModerationAction;
use App\Repository\Moderation\ModerationActionRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Moderation\PlayerReport;
use App\Repository\Moderation\PlayerReportRepository;

#[Route('/api/moderation_actions', name: 'moderationAction_')]
class ModerationActionController extends AbstractController
{
    public function __construct(
        private ModerationActionRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private PlayerReportRepository $playerReportRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['moderationAction:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $moderationAction = new ModerationAction();
        if (isset($data['actionType'])) $moderationAction->setActionType($data['actionType']);
        if (isset($data['reason'])) $moderationAction->setReason($data['reason']);
        if (isset($data['durationDays'])) $moderationAction->setDurationDays($data['durationDays']);
        if (isset($data['expiresAt'])) $moderationAction->setExpiresAt(new \DateTime($data['expiresAt']));
        if (isset($data['isActive'])) $moderationAction->setIsActive($data['isActive']);
        if (isset($data['createdAt'])) $moderationAction->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['revokedAt'])) $moderationAction->setRevokedAt(new \DateTime($data['revokedAt']));
        if (isset($data['revokeReason'])) $moderationAction->setRevokeReason($data['revokeReason']);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $moderationAction->setPlayer($rel_player);
        if (!isset($data['moderator'])) return $this->json(['error' => 'moderator is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_moderator = $this->playerRepository->find($data['moderator']);
        if (!$rel_moderator) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $moderationAction->setModerator($rel_moderator);
        if (array_key_exists('report', $data)) {
            $moderationAction->setReport($data['report'] !== null ? $this->playerReportRepository->find($data['report']) : null);
        }

        $errors = $this->validator->validate($moderationAction);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($moderationAction, flush: true);
        return $this->json($moderationAction, Response::HTTP_CREATED, context: ['groups' => ['moderationAction:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(ModerationAction $moderationAction): JsonResponse
    {
        return $this->json($moderationAction, context: ['groups' => ['moderationAction:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, ModerationAction $moderationAction): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['actionType'])) $moderationAction->setActionType($data['actionType']);
        if (isset($data['reason'])) $moderationAction->setReason($data['reason']);
        if (isset($data['durationDays'])) $moderationAction->setDurationDays($data['durationDays']);
        if (isset($data['expiresAt'])) $moderationAction->setExpiresAt(new \DateTime($data['expiresAt']));
        if (isset($data['isActive'])) $moderationAction->setIsActive($data['isActive']);
        if (isset($data['createdAt'])) $moderationAction->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['revokedAt'])) $moderationAction->setRevokedAt(new \DateTime($data['revokedAt']));
        if (isset($data['revokeReason'])) $moderationAction->setRevokeReason($data['revokeReason']);
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $moderationAction->setPlayer($rel_player);
        }
        if (isset($data['moderator'])) {
            $rel_moderator = $this->playerRepository->find($data['moderator']);
            if (!$rel_moderator) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $moderationAction->setModerator($rel_moderator);
        }
        if (array_key_exists('report', $data)) {
            $moderationAction->setReport($data['report'] !== null ? $this->playerReportRepository->find($data['report']) : null);
        }

        $errors = $this->validator->validate($moderationAction);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($moderationAction, flush: true);
        return $this->json($moderationAction, context: ['groups' => ['moderationAction:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(ModerationAction $moderationAction): JsonResponse
    {
        $this->repository->remove($moderationAction, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
