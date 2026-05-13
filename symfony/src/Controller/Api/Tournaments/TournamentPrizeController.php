<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\TournamentPrize;
use App\Repository\Tournaments\TournamentPrizeRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;

#[Route('/api/tournament_prizes', name: 'tournamentPrize_')]
class TournamentPrizeController extends AbstractController
{
    public function __construct(
        private TournamentPrizeRepository $repository,
        private ValidatorInterface $validator,
        private TournamentRepository $tournamentRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tournamentPrize:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournamentPrize = new TournamentPrize();
        if (isset($data['placementFrom'])) $tournamentPrize->setPlacementFrom($data['placementFrom']);
        if (isset($data['placementTo'])) $tournamentPrize->setPlacementTo($data['placementTo']);
        if (isset($data['prizeType'])) $tournamentPrize->setPrizeType($data['prizeType']);
        if (isset($data['amount'])) $tournamentPrize->setAmount($data['amount']);
        if (isset($data['description'])) $tournamentPrize->setDescription($data['description']);
        if (isset($data['packsCount'])) $tournamentPrize->setPacksCount($data['packsCount']);
        if (isset($data['seasonPoints'])) $tournamentPrize->setSeasonPoints($data['seasonPoints']);
        if (!isset($data['tournament'])) return $this->json(['error' => 'tournament is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_tournament = $this->tournamentRepository->find($data['tournament']);
        if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentPrize->setTournament($rel_tournament);

        $errors = $this->validator->validate($tournamentPrize);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentPrize, flush: true);
        return $this->json($tournamentPrize, Response::HTTP_CREATED, context: ['groups' => ['tournamentPrize:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TournamentPrize $tournamentPrize): JsonResponse
    {
        return $this->json($tournamentPrize, context: ['groups' => ['tournamentPrize:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TournamentPrize $tournamentPrize): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['placementFrom'])) $tournamentPrize->setPlacementFrom($data['placementFrom']);
        if (isset($data['placementTo'])) $tournamentPrize->setPlacementTo($data['placementTo']);
        if (isset($data['prizeType'])) $tournamentPrize->setPrizeType($data['prizeType']);
        if (isset($data['amount'])) $tournamentPrize->setAmount($data['amount']);
        if (isset($data['description'])) $tournamentPrize->setDescription($data['description']);
        if (isset($data['packsCount'])) $tournamentPrize->setPacksCount($data['packsCount']);
        if (isset($data['seasonPoints'])) $tournamentPrize->setSeasonPoints($data['seasonPoints']);
        if (isset($data['tournament'])) {
            $rel_tournament = $this->tournamentRepository->find($data['tournament']);
            if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentPrize->setTournament($rel_tournament);
        }

        $errors = $this->validator->validate($tournamentPrize);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentPrize, flush: true);
        return $this->json($tournamentPrize, context: ['groups' => ['tournamentPrize:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TournamentPrize $tournamentPrize): JsonResponse
    {
        $this->repository->remove($tournamentPrize, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
