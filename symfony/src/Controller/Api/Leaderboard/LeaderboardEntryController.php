<?php

namespace App\Controller\Api\Leaderboard;

use App\Entity\Leaderboard\LeaderboardEntry;
use App\Repository\Leaderboard\LeaderboardEntryRepository;
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

#[Route('/api/leaderboard_entries', name: 'leaderboardEntry_')]
class LeaderboardEntryController extends AbstractController
{
    public function __construct(
        private LeaderboardEntryRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private SeasonRepository $seasonRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['leaderboardEntry:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $leaderboardEntry = new LeaderboardEntry();
        if (isset($data['position'])) $leaderboardEntry->setPosition($data['position']);
        if (isset($data['rating'])) $leaderboardEntry->setRating($data['rating']);
        if (isset($data['wins'])) $leaderboardEntry->setWins($data['wins']);
        if (isset($data['losses'])) $leaderboardEntry->setLosses($data['losses']);
        if (isset($data['winRate'])) $leaderboardEntry->setWinRate($data['winRate']);
        if (isset($data['tournamentWins'])) $leaderboardEntry->setTournamentWins($data['tournamentWins']);
        if (isset($data['seasonPoints'])) $leaderboardEntry->setSeasonPoints($data['seasonPoints']);
        if (isset($data['updatedAt'])) $leaderboardEntry->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $leaderboardEntry->setPlayer($rel_player);
        if (!isset($data['season'])) return $this->json(['error' => 'season is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_season = $this->seasonRepository->find($data['season']);
        if (!$rel_season) return $this->json(['error' => 'Season not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $leaderboardEntry->setSeason($rel_season);

        $errors = $this->validator->validate($leaderboardEntry);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($leaderboardEntry, flush: true);
        return $this->json($leaderboardEntry, Response::HTTP_CREATED, context: ['groups' => ['leaderboardEntry:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(LeaderboardEntry $leaderboardEntry): JsonResponse
    {
        return $this->json($leaderboardEntry, context: ['groups' => ['leaderboardEntry:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, LeaderboardEntry $leaderboardEntry): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['position'])) $leaderboardEntry->setPosition($data['position']);
        if (isset($data['rating'])) $leaderboardEntry->setRating($data['rating']);
        if (isset($data['wins'])) $leaderboardEntry->setWins($data['wins']);
        if (isset($data['losses'])) $leaderboardEntry->setLosses($data['losses']);
        if (isset($data['winRate'])) $leaderboardEntry->setWinRate($data['winRate']);
        if (isset($data['tournamentWins'])) $leaderboardEntry->setTournamentWins($data['tournamentWins']);
        if (isset($data['seasonPoints'])) $leaderboardEntry->setSeasonPoints($data['seasonPoints']);
        if (isset($data['updatedAt'])) $leaderboardEntry->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $leaderboardEntry->setPlayer($rel_player);
        }
        if (isset($data['season'])) {
            $rel_season = $this->seasonRepository->find($data['season']);
            if (!$rel_season) return $this->json(['error' => 'Season not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $leaderboardEntry->setSeason($rel_season);
        }

        $errors = $this->validator->validate($leaderboardEntry);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($leaderboardEntry, flush: true);
        return $this->json($leaderboardEntry, context: ['groups' => ['leaderboardEntry:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(LeaderboardEntry $leaderboardEntry): JsonResponse
    {
        $this->repository->remove($leaderboardEntry, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
