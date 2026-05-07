<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\Game;
use App\Repository\Tournaments\GameRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\MatchRecord;
use App\Repository\Tournaments\MatchRecordRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/games', name: 'game_')]
class GameController extends AbstractController
{
    public function __construct(
        private GameRepository $repository,
        private ValidatorInterface $validator,
        private MatchRecordRepository $matchRecordRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['game:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $game = new Game();
        if (isset($data['gameNumber'])) $game->setGameNumber($data['gameNumber']);
        if (isset($data['winnerSide'])) $game->setWinnerSide($data['winnerSide']);
        if (isset($data['turnsPlayed'])) $game->setTurnsPlayed($data['turnsPlayed']);
        if (isset($data['durationSeconds'])) $game->setDurationSeconds($data['durationSeconds']);
        if (isset($data['endedBy'])) $game->setEndedBy($data['endedBy']);
        if (isset($data['replayUrl'])) $game->setReplayUrl($data['replayUrl']);
        if (!isset($data['match'])) return $this->json(['error' => 'match is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_match = $this->matchRecordRepository->find($data['match']);
        if (!$rel_match) return $this->json(['error' => 'Match not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $game->setMatch($rel_match);
        if (array_key_exists('winner', $data)) {
            $game->setWinner($data['winner'] !== null ? $this->playerRepository->find($data['winner']) : null);
        }

        $errors = $this->validator->validate($game);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($game, flush: true);
        return $this->json($game, Response::HTTP_CREATED, context: ['groups' => ['game:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Game $game): JsonResponse
    {
        return $this->json($game, context: ['groups' => ['game:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Game $game): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['gameNumber'])) $game->setGameNumber($data['gameNumber']);
        if (isset($data['winnerSide'])) $game->setWinnerSide($data['winnerSide']);
        if (isset($data['turnsPlayed'])) $game->setTurnsPlayed($data['turnsPlayed']);
        if (isset($data['durationSeconds'])) $game->setDurationSeconds($data['durationSeconds']);
        if (isset($data['endedBy'])) $game->setEndedBy($data['endedBy']);
        if (isset($data['replayUrl'])) $game->setReplayUrl($data['replayUrl']);
        if (isset($data['match'])) {
            $rel_match = $this->matchRecordRepository->find($data['match']);
            if (!$rel_match) return $this->json(['error' => 'Match not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $game->setMatch($rel_match);
        }
        if (array_key_exists('winner', $data)) {
            $game->setWinner($data['winner'] !== null ? $this->playerRepository->find($data['winner']) : null);
        }

        $errors = $this->validator->validate($game);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($game, flush: true);
        return $this->json($game, context: ['groups' => ['game:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Game $game): JsonResponse
    {
        $this->repository->remove($game, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
