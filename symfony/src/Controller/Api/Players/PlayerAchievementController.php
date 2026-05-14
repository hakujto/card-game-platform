<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\PlayerAchievement;
use App\Repository\Players\PlayerAchievementRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Players\Achievement;
use App\Repository\Players\AchievementRepository;

#[Route('/api/player_achievements', name: 'playerAchievement_')]
class PlayerAchievementController extends AbstractController
{
    public function __construct(
        private PlayerAchievementRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private AchievementRepository $achievementRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['playerAchievement:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerAchievement = new PlayerAchievement();
        if (isset($data['earnedAt'])) $playerAchievement->setEarnedAt(new \DateTime($data['earnedAt']));
        if (isset($data['progress'])) $playerAchievement->setProgress($data['progress']);
        if (isset($data['isCompleted'])) $playerAchievement->setIsCompleted($data['isCompleted']);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerAchievement->setPlayer($rel_player);
        if (!isset($data['achievement'])) return $this->json(['error' => 'achievement is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_achievement = $this->achievementRepository->find($data['achievement']);
        if (!$rel_achievement) return $this->json(['error' => 'Achievement not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerAchievement->setAchievement($rel_achievement);

        $errors = $this->validator->validate($playerAchievement);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $playerAchievement->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerAchievement, flush: true);
        return $this->json($playerAchievement, Response::HTTP_CREATED, context: ['groups' => ['playerAchievement:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlayerAchievement $playerAchievement): JsonResponse
    {
        return $this->json($playerAchievement, context: ['groups' => ['playerAchievement:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, PlayerAchievement $playerAchievement): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['earnedAt'])) $playerAchievement->setEarnedAt(new \DateTime($data['earnedAt']));
        if (isset($data['progress'])) $playerAchievement->setProgress($data['progress']);
        if (isset($data['isCompleted'])) $playerAchievement->setIsCompleted($data['isCompleted']);
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerAchievement->setPlayer($rel_player);
        }
        if (isset($data['achievement'])) {
            $rel_achievement = $this->achievementRepository->find($data['achievement']);
            if (!$rel_achievement) return $this->json(['error' => 'Achievement not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerAchievement->setAchievement($rel_achievement);
        }

        $errors = $this->validator->validate($playerAchievement);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $playerAchievement->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerAchievement, flush: true);
        return $this->json($playerAchievement, context: ['groups' => ['playerAchievement:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(PlayerAchievement $playerAchievement): JsonResponse
    {
        $this->repository->remove($playerAchievement, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
