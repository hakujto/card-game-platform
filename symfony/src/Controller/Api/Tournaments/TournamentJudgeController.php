<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\TournamentJudge;
use App\Repository\Tournaments\TournamentJudgeRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/tournament_judges', name: 'tournamentJudge_')]
class TournamentJudgeController extends AbstractController
{
    public function __construct(
        private TournamentJudgeRepository $repository,
        private ValidatorInterface $validator,
        private TournamentRepository $tournamentRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tournamentJudge:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournamentJudge = new TournamentJudge();
        if (isset($data['role'])) $tournamentJudge->setRole($data['role']);
        if (!isset($data['tournament'])) return $this->json(['error' => 'tournament is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_tournament = $this->tournamentRepository->find($data['tournament']);
        if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentJudge->setTournament($rel_tournament);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentJudge->setPlayer($rel_player);

        $errors = $this->validator->validate($tournamentJudge);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentJudge, flush: true);
        return $this->json($tournamentJudge, Response::HTTP_CREATED, context: ['groups' => ['tournamentJudge:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TournamentJudge $tournamentJudge): JsonResponse
    {
        return $this->json($tournamentJudge, context: ['groups' => ['tournamentJudge:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TournamentJudge $tournamentJudge): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['role'])) $tournamentJudge->setRole($data['role']);
        if (isset($data['tournament'])) {
            $rel_tournament = $this->tournamentRepository->find($data['tournament']);
            if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentJudge->setTournament($rel_tournament);
        }
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentJudge->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($tournamentJudge);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentJudge, flush: true);
        return $this->json($tournamentJudge, context: ['groups' => ['tournamentJudge:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TournamentJudge $tournamentJudge): JsonResponse
    {
        $this->repository->remove($tournamentJudge, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
