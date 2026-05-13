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

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerSeasonStats = new PlayerSeasonStats();
        if (isset($data['wins'])) $playerSeasonStats->setWins($data['wins']);
        if (isset($data['losses'])) $playerSeasonStats->setLosses($data['losses']);
        if (isset($data['draws'])) $playerSeasonStats->setDraws($data['draws']);
        if (isset($data['tournamentWins'])) $playerSeasonStats->setTournamentWins($data['tournamentWins']);
        if (isset($data['highestRank'])) $playerSeasonStats->setHighestRank($data['highestRank']);
        if (isset($data['seasonPoints'])) $playerSeasonStats->setSeasonPoints($data['seasonPoints']);
        if (array_key_exists('player', $data)) {
            $playerSeasonStats->setPlayer($data['player'] !== null ? $this->playerRepository->find($data['player']) : null);
        }
        if (!isset($data['season'])) return $this->json(['error' => 'season is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_season = $this->seasonRepository->find($data['season']);
        if (!$rel_season) return $this->json(['error' => 'Season not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerSeasonStats->setSeason($rel_season);

        $errors = $this->validator->validate($playerSeasonStats);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerSeasonStats, flush: true);
        return $this->json($playerSeasonStats, Response::HTTP_CREATED, context: ['groups' => ['playerSeasonStats:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        return $this->json($playerSeasonStats, context: ['groups' => ['playerSeasonStats:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['wins'])) $playerSeasonStats->setWins($data['wins']);
        if (isset($data['losses'])) $playerSeasonStats->setLosses($data['losses']);
        if (isset($data['draws'])) $playerSeasonStats->setDraws($data['draws']);
        if (isset($data['tournamentWins'])) $playerSeasonStats->setTournamentWins($data['tournamentWins']);
        if (isset($data['highestRank'])) $playerSeasonStats->setHighestRank($data['highestRank']);
        if (isset($data['seasonPoints'])) $playerSeasonStats->setSeasonPoints($data['seasonPoints']);
        if (array_key_exists('player', $data)) {
            $playerSeasonStats->setPlayer($data['player'] !== null ? $this->playerRepository->find($data['player']) : null);
        }
        if (isset($data['season'])) {
            $rel_season = $this->seasonRepository->find($data['season']);
            if (!$rel_season) return $this->json(['error' => 'Season not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerSeasonStats->setSeason($rel_season);
        }

        $errors = $this->validator->validate($playerSeasonStats);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerSeasonStats, flush: true);
        return $this->json($playerSeasonStats, context: ['groups' => ['playerSeasonStats:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(PlayerSeasonStats $playerSeasonStats): JsonResponse
    {
        $this->repository->remove($playerSeasonStats, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
