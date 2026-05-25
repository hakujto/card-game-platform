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

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlayerAchievement $playerAchievement): JsonResponse
    {
        return $this->json($playerAchievement, context: ['groups' => ['playerAchievement:read']]);
    }

    #[Route('/{id}/progress', name: 'incrementProgress', methods: ['PATCH'])]
    public function incrementProgress(PlayerAchievement $playerAchievement, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerAchievement->incrementProgress($data['amount'] ?? null);
        $this->repository->save($playerAchievement, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/complete', name: 'complete', methods: ['POST'])]
    public function complete(PlayerAchievement $playerAchievement): JsonResponse
    {
        $playerAchievement->complete();
        $this->repository->save($playerAchievement, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
