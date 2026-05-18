<?php

namespace App\Controller\Api\Tournaments;

use App\Entity\Tournaments\TournamentRegistration;
use App\Repository\Tournaments\TournamentRegistrationRepository;
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
use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;

#[Route('/api/tournament_registrations', name: 'tournamentRegistration_')]
class TournamentRegistrationController extends AbstractController
{
    public function __construct(
        private TournamentRegistrationRepository $repository,
        private ValidatorInterface $validator,
        private TournamentRepository $tournamentRepository,
        private PlayerRepository $playerRepository,
        private DeckRepository $deckRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tournamentRegistration:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournamentRegistration = new TournamentRegistration();
        if (isset($data['status'])) $tournamentRegistration->setStatus($data['status']);
        if (isset($data['seed'])) $tournamentRegistration->setSeed($data['seed']);
        if (isset($data['finalStanding'])) $tournamentRegistration->setFinalStanding($data['finalStanding']);
        if (isset($data['pointsEarned'])) $tournamentRegistration->setPointsEarned($data['pointsEarned']);
        if (isset($data['registeredAt'])) $tournamentRegistration->setRegisteredAt(new \DateTime($data['registeredAt']));
        if (!isset($data['tournament'])) return $this->json(['error' => 'tournament is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_tournament = $this->tournamentRepository->find($data['tournament']);
        if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentRegistration->setTournament($rel_tournament);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentRegistration->setPlayer($rel_player);
        if (!isset($data['deck'])) return $this->json(['error' => 'deck is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_deck = $this->deckRepository->find($data['deck']);
        if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tournamentRegistration->setDeck($rel_deck);

        $errors = $this->validator->validate($tournamentRegistration);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tournamentRegistration->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentRegistration, flush: true);
        return $this->json($tournamentRegistration, Response::HTTP_CREATED, context: ['groups' => ['tournamentRegistration:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TournamentRegistration $tournamentRegistration): JsonResponse
    {
        return $this->json($tournamentRegistration, context: ['groups' => ['tournamentRegistration:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['status'])) $tournamentRegistration->setStatus($data['status']);
        if (isset($data['seed'])) $tournamentRegistration->setSeed($data['seed']);
        if (isset($data['finalStanding'])) $tournamentRegistration->setFinalStanding($data['finalStanding']);
        if (isset($data['pointsEarned'])) $tournamentRegistration->setPointsEarned($data['pointsEarned']);
        if (isset($data['registeredAt'])) $tournamentRegistration->setRegisteredAt(new \DateTime($data['registeredAt']));
        if (isset($data['tournament'])) {
            $rel_tournament = $this->tournamentRepository->find($data['tournament']);
            if (!$rel_tournament) return $this->json(['error' => 'Tournament not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentRegistration->setTournament($rel_tournament);
        }
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentRegistration->setPlayer($rel_player);
        }
        if (isset($data['deck'])) {
            $rel_deck = $this->deckRepository->find($data['deck']);
            if (!$rel_deck) return $this->json(['error' => 'Deck not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tournamentRegistration->setDeck($rel_deck);
        }

        $errors = $this->validator->validate($tournamentRegistration);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tournamentRegistration->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tournamentRegistration, flush: true);
        return $this->json($tournamentRegistration, context: ['groups' => ['tournamentRegistration:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $this->repository->remove($tournamentRegistration, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/withdraw', name: 'withdraw', methods: ['POST'])]
    public function withdraw(TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $tournamentRegistration->withdraw();
        $this->repository->save($tournamentRegistration, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/disqualify', name: 'disqualify', methods: ['POST'])]
    public function disqualify(TournamentRegistration $tournamentRegistration, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tournamentRegistration->disqualify($data['reason'] ?? null);
        $this->repository->save($tournamentRegistration, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/promote', name: 'promoteFromWaitlist', methods: ['POST'])]
    public function promoteFromWaitlist(TournamentRegistration $tournamentRegistration): JsonResponse
    {
        $tournamentRegistration->promoteFromWaitlist();
        $this->repository->save($tournamentRegistration, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
