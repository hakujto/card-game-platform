<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\TournamentRound;
use App\Repository\Tournaments\TournamentRoundRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;

#[Route('/api/tournament_rounds', name: 'tournamentRound_')]
class TournamentRoundController extends AbstractController
{
    public function __construct(
        private TournamentRoundRepository $repository,
        private ValidatorInterface $validator,
        private TournamentRepository $tournamentRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tournamentRound:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournamentRound = new TournamentRound();
        if (isset($data['roundNumber'])) $tournamentRound->setRoundNumber($data['roundNumber']);
        if (isset($data['status'])) $tournamentRound->setStatus($data['status']);
        if (isset($data['startedAt'])) $tournamentRound->setStartedAt(new \DateTime($data['startedAt']));
        if (isset($data['endedAt'])) $tournamentRound->setEndedAt(new \DateTime($data['endedAt']));
        if (isset($data['timeLimitMinutes'])) $tournamentRound->setTimeLimitMinutes($data['timeLimitMinutes']);
        if (!isset($data['tournament'])) return $this->json(['error' => 'tournament is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_tournament = $this->tournamentRepository->find($data['tournament']);
        if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentRound->setTournament($rel_tournament);

        $errors = $this->validator->validate($tournamentRound);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentRound, flush: true);
        return $this->json($tournamentRound, Response::HTTP_CREATED, context: ['groups' => ['tournamentRound:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TournamentRound $tournamentRound): JsonResponse
    {
        return $this->json($tournamentRound, context: ['groups' => ['tournamentRound:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TournamentRound $tournamentRound): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['roundNumber'])) $tournamentRound->setRoundNumber($data['roundNumber']);
        if (isset($data['status'])) $tournamentRound->setStatus($data['status']);
        if (isset($data['startedAt'])) $tournamentRound->setStartedAt(new \DateTime($data['startedAt']));
        if (isset($data['endedAt'])) $tournamentRound->setEndedAt(new \DateTime($data['endedAt']));
        if (isset($data['timeLimitMinutes'])) $tournamentRound->setTimeLimitMinutes($data['timeLimitMinutes']);
        if (isset($data['tournament'])) {
            $rel_tournament = $this->tournamentRepository->find($data['tournament']);
            if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentRound->setTournament($rel_tournament);
        }

        $errors = $this->validator->validate($tournamentRound);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentRound, flush: true);
        return $this->json($tournamentRound, context: ['groups' => ['tournamentRound:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TournamentRound $tournamentRound): JsonResponse
    {
        $this->repository->remove($tournamentRound, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/start', name: 'start', methods: ['POST'])]
    public function start(TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->start();
        $this->repository->save($tournamentRound, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/complete', name: 'complete', methods: ['POST'])]
    public function complete(TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->complete();
        $this->repository->save($tournamentRound, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/pairings', name: 'generatePairings', methods: ['POST'])]
    public function generatePairings(TournamentRound $tournamentRound): JsonResponse
    {
        $tournamentRound->generatePairings();
        $this->repository->save($tournamentRound, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
