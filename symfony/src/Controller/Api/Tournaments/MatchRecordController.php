<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\MatchRecord;
use App\Repository\Tournaments\MatchRecordRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\TournamentRound;
use App\Repository\Tournaments\TournamentRoundRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Tournaments\Game;
use App\Repository\Tournaments\GameRepository;

#[Route('/api/matches', name: 'matchRecord_')]
class MatchRecordController extends AbstractController
{
    public function __construct(
        private MatchRecordRepository $repository,
        private ValidatorInterface $validator,
        private TournamentRoundRepository $tournamentRoundRepository,
        private PlayerRepository $playerRepository,
        private GameRepository $gameRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['matchRecord:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $matchRecord = new MatchRecord();
        if (isset($data['tableNumber'])) $matchRecord->setTableNumber($data['tableNumber']);
        if (isset($data['status'])) $matchRecord->setStatus($data['status']);
        if (isset($data['player1Wins'])) $matchRecord->setPlayer1Wins($data['player1Wins']);
        if (isset($data['player2Wins'])) $matchRecord->setPlayer2Wins($data['player2Wins']);
        if (isset($data['startedAt'])) $matchRecord->setStartedAt(new \DateTime($data['startedAt']));
        if (isset($data['endedAt'])) $matchRecord->setEndedAt(new \DateTime($data['endedAt']));
        if (isset($data['resultNotes'])) $matchRecord->setResultNotes($data['resultNotes']);
        if (array_key_exists('round', $data)) {
            $matchRecord->setRound($data['round'] !== null ? $this->tournamentRoundRepository->find($data['round']) : null);
        }
        if (!isset($data['player1'])) return $this->json(['error' => 'player1 is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player1 = $this->playerRepository->find($data['player1']);
        if (!$rel_player1) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $matchRecord->setPlayer1($rel_player1);
        if (array_key_exists('player2', $data)) {
            $matchRecord->setPlayer2($data['player2'] !== null ? $this->playerRepository->find($data['player2']) : null);
        }
        if (array_key_exists('games', $data)) {
            $matchRecord->setGames($data['games'] !== null ? $this->gameRepository->find($data['games']) : null);
        }

        $errors = $this->validator->validate($matchRecord);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($matchRecord, flush: true);
        return $this->json($matchRecord, Response::HTTP_CREATED, context: ['groups' => ['matchRecord:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(MatchRecord $matchRecord): JsonResponse
    {
        return $this->json($matchRecord, context: ['groups' => ['matchRecord:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, MatchRecord $matchRecord): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['tableNumber'])) $matchRecord->setTableNumber($data['tableNumber']);
        if (isset($data['status'])) $matchRecord->setStatus($data['status']);
        if (isset($data['player1Wins'])) $matchRecord->setPlayer1Wins($data['player1Wins']);
        if (isset($data['player2Wins'])) $matchRecord->setPlayer2Wins($data['player2Wins']);
        if (isset($data['startedAt'])) $matchRecord->setStartedAt(new \DateTime($data['startedAt']));
        if (isset($data['endedAt'])) $matchRecord->setEndedAt(new \DateTime($data['endedAt']));
        if (isset($data['resultNotes'])) $matchRecord->setResultNotes($data['resultNotes']);
        if (array_key_exists('round', $data)) {
            $matchRecord->setRound($data['round'] !== null ? $this->tournamentRoundRepository->find($data['round']) : null);
        }
        if (isset($data['player1'])) {
            $rel_player1 = $this->playerRepository->find($data['player1']);
            if (!$rel_player1) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $matchRecord->setPlayer1($rel_player1);
        }
        if (array_key_exists('player2', $data)) {
            $matchRecord->setPlayer2($data['player2'] !== null ? $this->playerRepository->find($data['player2']) : null);
        }
        if (array_key_exists('games', $data)) {
            $matchRecord->setGames($data['games'] !== null ? $this->gameRepository->find($data['games']) : null);
        }

        $errors = $this->validator->validate($matchRecord);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($matchRecord, flush: true);
        return $this->json($matchRecord, context: ['groups' => ['matchRecord:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(MatchRecord $matchRecord): JsonResponse
    {
        $this->repository->remove($matchRecord, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
