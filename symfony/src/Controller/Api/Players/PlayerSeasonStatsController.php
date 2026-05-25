<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\PlayerSeasonStats;
use App\Repository\Players\PlayerSeasonStatsRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Tournaments\Season;
use App\Repository\Tournaments\SeasonRepository;

#[Route('/api/player_season_statses', name: 'playerSeasonStats_')]
class PlayerSeasonStatsController extends AbstractController
{
    public function __construct(
        private PlayerSeasonStatsRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private SeasonRepository $seasonRepository,
    ) {}


    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['playerSeasonStats:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        return $this->json($playerSeasonStats, context: ['groups' => ['playerSeasonStats:read']]);
    }

    #[Route('/{id}/win-rate', name: 'winRate', methods: ['GET'])]
    public function winRate(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $result = $playerSeasonStats->winRate();
        $this->repository->save($playerSeasonStats, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/points', name: 'addPoints', methods: ['PATCH'])]
    public function addPoints(PlayerSeasonStats $playerSeasonStats, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerSeasonStats->addPoints($data['points'] ?? null);
        $this->repository->save($playerSeasonStats, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/tournament-win', name: 'recordTournamentWin', methods: ['POST'])]
    public function recordTournamentWin(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $playerSeasonStats->recordTournamentWin();
        $this->repository->save($playerSeasonStats, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
